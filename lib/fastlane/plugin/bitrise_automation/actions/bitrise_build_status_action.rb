require 'fastlane/action'
require_relative '../helper/bitrise_automation_helper'

module Fastlane
  module Actions
    class BitriseBuildStatusAction < Action
      def self.run(params)
        status = get_status(params, params[:build_slug])
        FastlaneCore::PrintTable.print_values(config: status,
                                              title: "Bitrise build '#{params[:build_slug]}' status")
        status
      end

      def self.get_status(params, build_slug)
        response = Helper::BitriseRequestHelper.get(params, "builds/#{build_slug}")

        if response.code == "200"
          json_response = JSON.parse(response.body)['data']
        else
          UI.crash!("Error fetching build status on Bitrise.io. Status code: #{response.code}. #{response}")
        end

        build_infos = {}
        build_infos["is_on_hold"] = json_response["is_on_hold"]
        build_infos["status"] = json_response["status"]
        build_infos["status_text"] = json_response["status_text"]
        build_infos["abort_reason"] = json_response["abort_reason"]
        build_infos
      end

      def self.description
        "Get the status of the Bitrise build"
      end

      def self.authors
        ["Mario Cecchi", "Henrique Alves"]
      end

      def self.return_value
        "Returns the information of the Bitrise build"
      end

      def self.return_type
        :hash
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
          FastlaneCore::ConfigItem.new(key: :build_slug,
                                  env_name: "BITRISE_BUILD_SLUG",
                               description: "The slug that identifies the build on Bitrise",
                                  optional: false,
                                      type: String)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
