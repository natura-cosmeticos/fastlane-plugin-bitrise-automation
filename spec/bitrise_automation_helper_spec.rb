describe Fastlane::Helper::BitriseRequestHelper do
  describe 'request post' do
    it 'provides the authentication token on the header' do
      stub_request(:post, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
        with(headers: { 'Content-Type' => 'application/json', 'Authorization' => 'tokenABC' })

      params = { app_slug: 'appslug123', access_token: 'tokenABC' }
      request = Fastlane::Helper::BitriseRequestHelper.post(params, 'builds', '{}')
    end

    it 'passes the provided body on request' do
      expected_body = '{"test":"bla"}'
      stub_request(:post, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
        with(body: expected_body)

      params = { app_slug: 'appslug123', access_token: 'tokenABC' }
      request = Fastlane::Helper::BitriseRequestHelper.post(params, 'builds', expected_body)
    end
  end

  describe 'request get' do
    it 'provides the authentication token on the header' do
      stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds/bla").
        with(headers: { 'Content-Type' => 'application/json', 'Authorization' => 'tokenABC' })

      params = { app_slug: 'appslug123', access_token: 'tokenABC' }
      request = Fastlane::Helper::BitriseRequestHelper.get(params, 'builds/bla')
    end
  end
end
