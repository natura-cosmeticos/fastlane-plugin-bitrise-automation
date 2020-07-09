build_artifacts_success = {
  "data" => [
    {
      "title" => "file.json",
      "artifact_type" => "file",
      "artifact_meta" => nil,
      "is_public_page_enabled" => false,
      "slug" => "3301a655390a49e1",
      "file_size_bytes" => 375
    }
  ],
  "paging" => {
    "page_item_limit" => 10,
    "total_item_count" => 1
  }
}.to_json

artifact_details_success = {
  "data" => {
    "title" => "file.json",
    "artifact_type" => "file",
    "artifact_meta" => nil,
    "expiring_download_url" => "https://bitrise-artifacts.example.com/3301a655390a49e1",
    "is_public_page_enabled" => false,
    "slug" => "3301a655390a49e1",
    "public_install_page_url" => "",
    "file_size_bytes" => 375
  }
}.to_json

artifact_json_file = {
  "output" => "whatever"
}.to_json

describe Fastlane::Actions::BitriseBuildArtifactsAction do
  describe 'bitrise build artifacts list' do
    it 'calls the Bitrise API with the provided parameters and returns list of artifacts' do
      stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds/build789/artifacts").
        to_return(body: build_artifacts_success, status: 200)

      response = Fastlane::Actions::BitriseBuildArtifactsAction.run(
        app_slug: "appslug123",
        build_slug: "build789"
      )

      expect(response.size).to eq(1)
      expect(response[0]['title']).to eq('file.json')
      expect(response[0]['artifact_type']).to eq('file')
      expect(response[0]['slug']).to eq('3301a655390a49e1')
      expect(response[0]['file_size_bytes']).to eq(375)
    end

    it 'crashes when the Bitrise API returns an unexpected status code' do
      stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds/build789/artifacts").
        to_return(body: '{}', status: 400)

      expect do
        Fastlane::Actions::BitriseBuildArtifactsAction.run(
          app_slug: "appslug123",
          build_slug: "build789"
        )
      end.to raise_error(FastlaneCore::Interface::FastlaneCrash)
    end
  end

  describe 'artifact download' do
    before(:each) do
      stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds/build789/artifacts").
        to_return(body: build_artifacts_success, status: 200)
      stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds/build789/artifacts/3301a655390a49e1").
        to_return(body: artifact_details_success, status: 200)
      stub_request(:get, "https://bitrise-artifacts.example.com/3301a655390a49e1").
        to_return(body: artifact_json_file, status: 200)
    end

    it 'creates the artifacts directory if it does not already exist' do
      allow(Dir).to receive(:exist?).with('artifacts').and_return(false)
      allow(Dir).to receive(:mkdir)

      response = Fastlane::Actions::BitriseBuildArtifactsAction.run(
        app_slug: "appslug123",
        build_slug: "build789",
        download: true
      )

      expect(Dir).to have_received(:mkdir).with('artifacts')
    end

    it 'does not create the artifacts directory if it already exists' do
      allow(Dir).to receive(:exist?).with('artifacts').and_return(true)
      allow(Dir).to receive(:mkdir)

      response = Fastlane::Actions::BitriseBuildArtifactsAction.run(
        app_slug: "appslug123",
        build_slug: "build789",
        download: true
      )

      expect(Dir).not_to(have_received(:mkdir).with('artifacts'))
    end

    it 'fetches artifact details and downloads them when the download flag is on' do
      allow(Dir).to receive(:exist?).with('artifacts').and_return(true)
      allow(Dir).to receive(:mkdir)
      allow(Fastlane::Actions::BitriseBuildArtifactsAction).to receive(:sh)

      response = Fastlane::Actions::BitriseBuildArtifactsAction.run(
        app_slug: "appslug123",
        build_slug: "build789",
        download: true
      )

      expect(Fastlane::Actions::BitriseBuildArtifactsAction).to have_received(:sh).with("curl --fail --silent -o 'artifacts/file.json' 'https://bitrise-artifacts.example.com/3301a655390a49e1'")
    end

    it 'crashes if fetching artifact details returns an unexpected response' do
      allow(Dir).to receive(:exist?).with('artifacts').and_return(true)
      allow(Dir).to receive(:mkdir)
      stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds/build789/artifacts/3301a655390a49e1").
        to_return(body: '{}', status: 400)

      expect do
        response = Fastlane::Actions::BitriseBuildArtifactsAction.run(
          app_slug: "appslug123",
          build_slug: "build789",
          download: true
        )
      end.to raise_error(FastlaneCore::Interface::FastlaneCrash)
    end
  end
end
