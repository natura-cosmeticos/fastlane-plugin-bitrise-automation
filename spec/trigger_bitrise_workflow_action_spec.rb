build_created_response = {
  "build_number" => 100,
  "build_slug" => "abc123",
  "build_url" => "http://example.com/builds/100",
  "message" => "string",
  "service" => "string",
  "slug" => "13673618",
  "status" => "on_hold",
  "triggered_workflow" => "workflow_name"
}.to_json

describe Fastlane::Actions::TriggerBitriseWorkflowAction do
  describe 'trigger bitrise build' do
    it 'calls the Bitrise API with the provided parameters and returns build info' do
      expected_request_payload = {
        hook_info: {
          type: "bitrise"
        },
        build_params: {
          workflow_id: "workflow_name",
          commit_hash: "commit_hash",
          commit_message: "build_message"
        }
      }
      stub_request(:post, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
        with(body: expected_request_payload).
        to_return(body: build_created_response, status: 201)

      response = Fastlane::Actions::TriggerBitriseWorkflowAction.run(
        app_slug: "appslug123",
        workflow: "workflow_name",
        commit_hash: "commit_hash",
        build_message: "build_message",
        wait_for_build: false
      )

      expect(response['status']).to eq("on_hold")
      expect(response['build_url']).to eq("http://example.com/builds/100")
      expect(response['build_number']).to eq(100)
      expect(response['build_slug']).to eq("abc123")
    end

    it 'crashes when the Bitrise API returns an unexpected status code' do
      stub_request(:post, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
        to_return(body: '{}', status: 400)

      expect do
        response = Fastlane::Actions::TriggerBitriseWorkflowAction.run(
          app_slug: "appslug123",
          workflow: "workflow_name",
          commit_hash: "commit_hash",
          build_message: "build_message",
          wait_for_build: false
        )
      end.to raise_error(FastlaneCore::Interface::FastlaneCrash)
    end
  end

  describe 'when download_artifact is turned on' do
    before(:each) do
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

      stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds/abc123/artifacts").
        to_return(body: build_artifacts_success, status: 200)
      stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds/abc123/artifacts/3301a655390a49e1").
        to_return(body: artifact_details_success, status: 200)
      stub_request(:get, "https://bitrise-artifacts.example.com/3301a655390a49e1").
        to_return(body: artifact_json_file, status: 200)

      build_details_success = {
        "data" => {
          "is_on_hold" => false,
          "status" => 1,
          "status_text" => "success"
        }
      }.to_json
      stub_request(:post, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
        to_return(body: build_created_response, status: 201)
      stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds/abc123").
        to_return(body: build_details_success, status: 200)
    end

    it 'downloads the artifacts' do
      allow(Fastlane::Actions::BitriseBuildArtifactsAction).to receive(:download_artifact)

      response = Fastlane::Actions::TriggerBitriseWorkflowAction.run(
        app_slug: "appslug123",
        workflow: "workflow_name",
        commit_hash: "commit_hash",
        build_message: "build_message",
        download_artifacts: true,
        wait_for_build: true
      )

      expect(Fastlane::Actions::BitriseBuildArtifactsAction)
        .to have_received(:download_artifact)
    end
  end

  describe 'when wait_for_build is turned on' do
    it 'queries the status after triggering the build' do
      build_details_success = {
        "data" => {
          "is_on_hold" => false,
          "status" => 1,
          "status_text" => "success"
        }
      }.to_json
      stub_request(:post, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
        to_return(body: build_created_response, status: 201)
      stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds/abc123").
        to_return(body: build_details_success, status: 200)

      response = Fastlane::Actions::TriggerBitriseWorkflowAction.run(
        app_slug: "appslug123",
        workflow: "workflow_name",
        commit_hash: "commit_hash",
        build_message: "build_message",
        wait_for_build: true
      )

      expect(response['status']).to eq("success")
    end

    it 'queries the status repeatedly until build has finished' do
      allow_any_instance_of(Object).to receive(:sleep)
      build_details_waiting = {
        "data" => {
          "is_on_hold" => true,
          "status" => 0,
          "status_text" => "on hold"
        }
      }.to_json
      build_details_success = {
        "data" => {
          "is_on_hold" => false,
          "status" => 1,
          "status_text" => "success"
        }
      }.to_json
      stub_request(:post, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
        to_return(body: build_created_response, status: 201)
      stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds/abc123").
        to_return({ body: build_details_waiting, status: 200 }, { body: build_details_success, status: 200 })

      response = Fastlane::Actions::TriggerBitriseWorkflowAction.run(
        app_slug: "appslug123",
        workflow: "workflow_name",
        commit_hash: "commit_hash",
        build_message: "build_message",
        wait_for_build: true
      )

      expect(response['status']).to eq("success")
    end

    it 'throws a build failure error if the build has failed' do
      allow_any_instance_of(Object).to receive(:sleep)
      build_details_failure = {
        "data" => {
          "is_on_hold" => false,
          "status" => 2,
          "status_text" => "failed"
        }
      }.to_json
      stub_request(:post, "https://api.bitrise.io/v0.1/apps/appslug123/builds").
        to_return(body: build_created_response, status: 201)
      stub_request(:get, "https://api.bitrise.io/v0.1/apps/appslug123/builds/abc123").
        to_return(body: build_details_failure, status: 200)

      expect do
        response = Fastlane::Actions::TriggerBitriseWorkflowAction.run(
          app_slug: "appslug123",
          workflow: "workflow_name",
          commit_hash: "commit_hash",
          build_message: "build_message",
          wait_for_build: true
        )
      end.to raise_error(FastlaneCore::Interface::FastlaneBuildFailure)
    end
  end
end
