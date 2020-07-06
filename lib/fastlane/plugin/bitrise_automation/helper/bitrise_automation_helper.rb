require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class BitriseRequestHelper
      def self.post(params, path, body)
        uri = URI.parse("https://api.bitrise.io/v0.1/apps/#{params[:app_slug]}/#{path}")
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json', 'Authorization' => params[:access_token] })
        request.body = body
        https.request(request)
      end
    end
  end
end
