describe Fastlane::Actions::TriggerBitriseWorkflowAction do
  describe 'trigger bitrise build' do
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
        workflow_name: "workflow_name",
        commit_hash: "commit_hash",
        build_message: "build_message",
        async: true
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
          workflow_name: "workflow_name",
          commit_hash: "commit_hash",
          build_message: "build_message",
          async: true
        )
      end.to raise_error(FastlaneCore::Interface::FastlaneCrash)
    end

    it 'when async is false, queries the status after triggering the build' do
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
        workflow_name: "workflow_name",
        commit_hash: "commit_hash",
        build_message: "build_message",
        async: false
      )

      expect(response['status']).to eq("success")
    end

    it 'when async is false, queries the status until build is finished' do
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
        workflow_name: "workflow_name",
        commit_hash: "commit_hash",
        build_message: "build_message",
        async: false
      )

      expect(response['status']).to eq("success")
    end

    it 'when async is false, if builds returns a failed status the action should raise build failure' do
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
          workflow_name: "workflow_name",
          commit_hash: "commit_hash",
          build_message: "build_message",
          async: false
        )
      end.to raise_error(FastlaneCore::Interface::FastlaneBuildFailure)
    end
  end
end
