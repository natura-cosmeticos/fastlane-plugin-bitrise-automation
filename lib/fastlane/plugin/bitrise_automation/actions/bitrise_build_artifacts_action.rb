require 'fastlane/action'
require_relative '../helper/bitrise_automation_helper'

module Fastlane
  module Actions
    class BitriseBuildArtifactsAction < Action
      def self.run(params)
        response = Helper::BitriseRequestHelper.get(params, "builds/#{params[:build_slug]}/artifacts")

        if response.code == "200"
          json_response = JSON.parse(response.body)['data']
        else
          UI.crash!("Error fetching build artifacts list on Bitrise.io. Status code: #{response.code}. #{response}")
        end

        UI.message("Found #{json_response.size} artifacts on Bitrise for build #{params[:build_slug]}.")

        artifacts = json_response.map do |artifact|
          {
            "title" => artifact["title"],
            "artifact_type" => artifact["artifact_type"],
            "slug" => artifact["slug"],
            "file_size_bytes" => artifact["file_size_bytes"]
          }
        end

        artifacts.each do |artifact|
          FastlaneCore::PrintTable.print_values(config: artifact,
                                                title: artifact['title'])
        end

        if params[:download] && !artifacts.empty?
          artifacts_dir = 'artifacts'
          UI.message("Download option is on. Will start download of #{artifacts.size} artifacts to '#{artifacts_dir}'.")
          Dir.mkdir(artifacts_dir) unless Dir.exist?(artifacts_dir)

          artifacts.each do |artifact|
            UI.message("Fetching artifact '#{artifact['title']}' of type '#{artifact['artifact_type']}' (#{artifact['file_size_bytes']} bytes)...")
            artifact_details = get_artifact_details(params, artifact['slug'])

            download_artifact(artifact_details, artifacts_dir)
            UI.message("Finished downloading artifact '#{artifact['title']}'.")
          end
        end

        artifacts
      end

      def self.get_artifact_details(params, artifact_slug)
        response = Helper::BitriseRequestHelper.get(params, "builds/#{params[:build_slug]}/artifacts/#{artifact_slug}")

        if response.code == "200"
          json_response = JSON.parse(response.body)['data']
        else
          UI.crash!("Error fetching build artifacts details on Bitrise.io. Status code: #{response.code}. #{response}")
        end

        json_response
      end

      def self.download_artifact(artifact, dir)
        file_name = artifact['title']
        url = artifact['expiring_download_url']

        sh("curl --fail --silent -o '#{dir}/#{file_name}' '#{url}'")
      end

      def self.description
        "Get the list or full contents of the artifacts produced by a build on Bitrise"
      end

      def self.authors
        ["Mario Cecchi", "Henrique Alves"]
      end

      def self.return_value
        "Returns the list of artifacts produced by a build on Bitrise"
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
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :download,
                                  env_name: "BITRISE_ARTIFACTS_DOWNLOAD",
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
