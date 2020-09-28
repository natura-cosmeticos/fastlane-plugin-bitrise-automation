require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class BitriseRequestHelper
      MAX_RETRY_ATTEMPTS = 2
      class << self
        def get(params, path)
          request = Net::HTTP::Get.new("/v0.1/apps/#{params[:app_slug]}/#{path}", bitrise_headers(params[:access_token]))
          request_with_retries(request)
        end

        def post(params, path, body)
          request = Net::HTTP::Post.new("/v0.1/apps/#{params[:app_slug]}/#{path}", bitrise_headers(params[:access_token]))
          request.body = body
          request_with_retries(request)
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

        def request_with_retries(request)
          retries = 0
          begin
            response = bitrise_client.request(request)
            if response.code.start_with?("5")
              UI.error("Bitrise returned a server-side error. Status code: #{response.code}. #{response}")
              raise "Bitrise API error: #{response.code}"
            end
          rescue StandardError => e
            UI.error("There was an error making the request to Bitrise (retries: #{retries}). #{e}")
            if retries < MAX_RETRY_ATTEMPTS
              retries += 1
              sleep(15)
              UI.error("Retrying request (attempt #{retries})")
              retry
            else
              UI.error("All retry attempts failed.")
              raise e
            end
          end
          response
        end
      end
    end
  end
end
