describe Fastlane::Helper::BitriseRequestHelper do
  params = { app_slug: 'appslug123', access_token: 'tokenABC' }

  describe 'request post' do
    it 'provides the authentication token on the header' do
      stub_request(:post, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
        with(headers: { 'Content-Type' => 'application/json', 'Authorization' => 'tokenABC' })

      request = Fastlane::Helper::BitriseRequestHelper.post(params, 'builds', '{}')
    end

    it 'passes the provided body on request' do
      expected_body = '{"test":"bla"}'
      stub_request(:post, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
        with(body: expected_body)

      request = Fastlane::Helper::BitriseRequestHelper.post(params, 'builds', expected_body)
    end

    it 'retries request when it fails with 5xx error' do
      allow_any_instance_of(Object).to receive(:sleep)
      expected_response = '{"test":"bla"}'
      stub_request = stub_request(:post, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
                     to_return(status: 503, body: '').times(1).then.
                     to_return(status: 200, body: expected_response)

      response = Fastlane::Helper::BitriseRequestHelper.post(params, 'builds', 'body')

      assert_requested(stub_request, times: 2)
      expect(response.body).to eq(expected_response)
    end

    it 'retries request when it fails with network error' do
      allow_any_instance_of(Object).to receive(:sleep)
      expected_response = '{"test":"bla"}'
      stub_request = stub_request(:post, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
                     to_timeout.times(1).then.
                     to_return(status: 200, body: expected_response)

      response = Fastlane::Helper::BitriseRequestHelper.post(params, 'builds', 'body')

      assert_requested(stub_request, times: 2)
      expect(response.body).to eq(expected_response)
    end

    it 'retries request twice before giving up' do
      allow_any_instance_of(Object).to receive(:sleep)
      stub_request = stub_request(:post, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
                     to_return(status: 503).times(5).then.
                     to_return(status: 200)

      expect do
        response = Fastlane::Helper::BitriseRequestHelper.post(params, 'builds', 'body')
      end.to raise_error
    end
  end

  describe 'request get' do
    it 'provides the authentication token on the header' do
      stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds/bla").
        with(headers: { 'Content-Type' => 'application/json', 'Authorization' => 'tokenABC' })

      request = Fastlane::Helper::BitriseRequestHelper.get(params, 'builds/bla')
    end

    it 'retries request when it fails with 5xx error' do
      allow_any_instance_of(Object).to receive(:sleep)
      expected_response = '{"test":"bla"}'
      stub_request = stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
                     to_return(status: 503, body: '').times(1).then.
                     to_return(status: 200, body: expected_response)

      response = Fastlane::Helper::BitriseRequestHelper.get(params, 'builds')

      assert_requested(stub_request, times: 2)
      expect(response.body).to eq(expected_response)
    end

    it 'retries request when it fails with network error' do
      allow_any_instance_of(Object).to receive(:sleep)
      expected_response = '{"test":"bla"}'
      stub_request = stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
                     to_timeout.times(1).then.
                     to_return(status: 200, body: expected_response)

      response = Fastlane::Helper::BitriseRequestHelper.get(params, 'builds')

      assert_requested(stub_request, times: 2)
      expect(response.body).to eq(expected_response)
    end

    it 'retries request twice before giving up' do
      allow_any_instance_of(Object).to receive(:sleep)
      stub_request = stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
                     to_return(status: 503).times(5).then.
                     to_return(status: 200)

      expect do
        response = Fastlane::Helper::BitriseRequestHelper.get(params, 'builds')
      end.to raise_error
    end
  end
end
