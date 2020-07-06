require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class BitriseRequestHelper
      class << self
        def get(params, path)
          request = Net::HTTP::Get.new("/v0.1/apps/#{params[:app_slug]}/#{path}", bitrise_headers(params[:access_token]))
          bitrise_client.request(request)
        end

        def post(params, path, body)
          request = Net::HTTP::Post.new("/v0.1/apps/#{params[:app_slug]}/#{path}", bitrise_headers(params[:access_token]))
          request.body = body
          bitrise_client.request(request)
        end

        private

        def bitrise_client
          uri = URI.parse("https://api.bitrise.io/")
          https = Net::HTTP.new(uri.host, uri.port)
          https.use_ssl = true
          https
        end

        def bitrise_headers(access_token)
          { 'Content-Type' => 'application/json', 'Authorization' => access_token }
        end
      end
    end
  end
end
