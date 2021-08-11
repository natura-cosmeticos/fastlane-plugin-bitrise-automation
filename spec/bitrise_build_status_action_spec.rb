describe Fastlane::Actions::BitriseBuildStatusAction do
  describe 'get bitrise build status' do
    it 'calls the Bitrise API with the provided parameters and returns build info' do
      build_details_success = {
        "data" => {
          "is_on_hold" => false,
          "status" => 1,
          "status_text" => "success",
          "abort_reason" => "bla"
        }
      }.to_json
      stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds/build789").
        to_return(body: build_details_success, status: 200)

      response = Fastlane::Actions::BitriseBuildStatusAction.run(
        app_slug: "appslug123",
        build_slug: "build789"
      )

      expect(response['status']).to eq(1)
      expect(response['status_text']).to eq("success")
      expect(response['is_on_hold']).to eq(false)
      expect(response['abort_reason']).to eq("bla")
    end

    it 'crashes when the Bitrise API returns an unexpected status code' do
      stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds/build789").
        to_return(body: '{}', status: 400)

      expect do
        Fastlane::Actions::BitriseBuildStatusAction.run(
          app_slug: "appslug123",
          build_slug: "build789"
        )
      end.to raise_error(FastlaneCore::Interface::FastlaneCrash)
    end
  end

  describe 'return type' do
    it 'is :hash' do
      expect(Fastlane::Actions::BitriseBuildStatusAction.return_type).to eq(:hash)
    end
  end
end
