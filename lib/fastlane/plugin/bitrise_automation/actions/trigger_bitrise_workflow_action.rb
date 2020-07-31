require 'fastlane/action'
require_relative '../helper/bitrise_automation_helper'

module Fastlane
  module Actions
    class TriggerBitriseWorkflowAction < Action
      def self.run(params)
        UI.message("Requesting new Bitrise.io build for workflow '#{params[:workflow]}'...")

        response = Helper::BitriseRequestHelper.post(params, 'builds', {
          hook_info: {
            type: "bitrise"
          },
          build_params: {
            workflow_id: params[:workflow],
            commit_hash: params[:commit_hash],
            commit_message: params[:build_message]
          }
        }.to_json)

        if response.code == "201"
          json_response = JSON.parse(response.body)
          UI.success("Build #{json_response['build_number']} triggered successfully on Bitrise 🚀 URL: #{json_response['build_url']}")
          FastlaneCore::PrintTable.print_values(config: json_response,
                                                title: "Bitrise API response")
        else
          UI.crash!("Error requesting new build on Bitrise.io. Status code: #{response.code}. #{response.body}")
        end

        build_infos = {}
        build_infos["status"] = json_response["status"]
        build_infos["build_url"] = json_response["build_url"]
        build_infos["build_number"] = json_response["build_number"]
        build_infos["build_slug"] = json_response["build_slug"]

        if params[:wait_for_build]
          build_status = wait_until_build_completion(params, build_infos["build_slug"])

          if params[:download_artifacts]
            BitriseBuildArtifactsAction.get_artifacts(params, build_infos["build_slug"])
          end

          build_infos["status"] = build_status["status_text"]
          if build_status["status"] == 1
            UI.success("Build has finished successfully on Bitrise!")
          elsif build_status["status"] == 2
            UI.build_failure!("Build has FAILED on Bitrise. Check more details at #{build_infos['build_url']}.")
          elsif build_status["status"] == 3 || build_status["status"] == 4
            UI.build_failure!("Build has been ABORTED on Bitrise. Abort reason: '#{build_status['abort_reason']}'. Check more details at #{build_infos['build_url']}.")
          else
            UI.build_failure!("Build has ended with unknown status on Bitrise: #{build_status}. Check more details at #{build_infos['build_url']}.")
          end
        end

        build_infos
      end

      def self.wait_until_build_completion(params, build_slug)
        build_status = {}
        loop do
          build_status = BitriseBuildStatusAction.get_status(params, build_slug)

          break if build_status['status'] != 0

          if build_status['is_on_hold']
            UI.message("Build is still on hold. Sleeping...")
          else
            UI.message("Build is running with status '#{build_status['status_text']}'. Sleeping...")
          end

          sleep(30)
        end
        build_status
      end

      def self.description
        "Trigger a Bitrise workflow with the specified parameters, synchronously or asynchronously"
      end

      def self.authors
        ["Mario Cecchi", "Henrique Alves"]
      end

      def self.return_value
        "Returns the information of the Bitrise build"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :app_slug,
                                  env_name: "BITRISE_APP_SLUG",
                               description: "The app slug of the project on Bitrise",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :access_token,
                                  env_name: "BITRISE_ACCESS_TOKEN",
                               description: "The personal access token used to call Bitrise API",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :workflow,
                                  env_name: "BITRISE_WORKFLOW",
                               description: "The name of the workflow to trigger",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :commit_hash,
                                  env_name: "BITRISE_BUILD_COMMIT_HASH",
                               description: "The hash of the commit that will be checked out",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :build_message,
                                  env_name: "BITRISE_BUILD_MESSAGE",
                               description: "A custom message that will be used to identify the build",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :wait_for_build,
                                  env_name: "BITRISE_WAIT_FOR_BUILD",
                               description: "Whether the action should wait until the build finishes or return immediately after requesting the build",
                                  optional: true,
                             default_value: false,
                                 is_string: false),
          FastlaneCore::ConfigItem.new(key: :download_artifacts,
                                  env_name: "BITRISE_DOWNLOAD_ARTIFACTS",
                               description: "Whether to download or not the produced artifacts",
                                  optional: true,
                             default_value: false,
                                 is_string: false)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
