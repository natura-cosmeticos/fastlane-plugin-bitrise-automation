describe Fastlane::Helper::BitriseRequestHelper do
  describe 'request post' do
    it 'provides the authentication token on the header' do
      stub_request(:post, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
        with(headers: { 'Content-Type' => 'application/json', 'Authorization' => 'tokenABC' })

      params = { app_slug: 'appslug123', access_token: 'tokenABC' }
      request = Fastlane::Helper::BitriseRequestHelper.post(params, 'builds', '{}')
    end

    it 'calls the specified path inside the app domain' do
      stub_request(:post, "https://api.bitrise.io/v0.1/apps/appslug123/some_random_action")

      params = { app_slug: 'appslug123', access_token: 'tokenABC' }
      request = Fastlane::Helper::BitriseRequestHelper.post(params, 'some_random_action', '{}')
    end
  end
end
