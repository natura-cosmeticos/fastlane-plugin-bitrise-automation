require 'fastlane/action'
require_relative '../helper/bitrise_automation_helper'

module Fastlane
  module Actions
    class TriggerBitriseWorkflowAction < Action
      def self.run(params)
        UI.verbose("Requesting new Bitrise.io build...")

        build_request_payload = {
          hook_info: {
            type: "bitrise"
          },
          build_params: {
            workflow_id: params[:workflow_name],
            commit_hash: params[:commit_hash],
            commit_message: params[:build_message]
          }
        }.to_json
        response = Helper::BitriseRequestHelper.post(params, 'builds', build_request_payload)

        if response.code == "201"
          json_response = JSON.parse(response.body)
          UI.success("Build triggered successfully 🚀 URL: #{json_response['build_url']}")
          FastlaneCore::PrintTable.print_values(config: json_response,
                                                hide_keys: [],
                                                title: "Bitrise API response")
        else
          UI.crash!("Error requesting new build on Bitrise.io. Status code: #{response.code}. #{response}")
        end

        build_infos = {}
        build_infos["status"] = json_response["status"]
        build_infos["build_url"] = json_response["build_url"]
        build_infos["build_number"] = json_response["build_number"]
        build_infos["build_slug"] = json_response["build_slug"]
        build_infos
      end

      def self.description
        "Trigger a Bitrise workflow with the specified parameters"
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
                                  env_name: "BITRISE_AUTOMATION_APP_SLUG",
                               description: "The app slug of the project on Bitrise",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :access_token,
                                  env_name: "BITRISE_AUTOMATION_ACCESS_TOKEN",
                               description: "The personal access token used to call Bitrise API",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :workflow,
                                  env_name: "BITRISE_AUTOMATION_WORKFLOW",
                               description: "The name of the workflow on Bitrise",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :commit_hash,
                                  env_name: "BITRISE_AUTOMATION_COMMIT_HASH",
                               description: "The commit hash to be used on the build",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :build_message,
                                  env_name: "BITRISE_AUTOMATION_BUILD_MESSAGE",
                               description: "A custom message that will be used to identify the build",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :async,
                                  env_name: "BITRISE_AUTOMATION_ASYNC",
                               description: "Whether the action should return immediately after requesting the build or wait until it finishes running",
                                  optional: false,
                                      type: Boolean)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end