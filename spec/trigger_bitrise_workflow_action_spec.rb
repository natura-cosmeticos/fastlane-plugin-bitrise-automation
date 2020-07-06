describe Fastlane::Actions::TriggerBitriseWorkflowAction do
  describe 'trigger bitrise build' do
    it 'calls the Bitrise API with the provided parameters and returns build info' do
      trigger_build_response = {
        "build_number" => 100,
        "build_slug" => "abc123",
        "build_url" => "http://example.com/builds/100",
        "message" => "string",
        "service" => "string",
        "slug" => "13673618",
        "status" => "on_hold",
        "triggered_workflow" => "workflow_name"
      }.to_json
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
        to_return(body: trigger_build_response, status: 201)

      response = Fastlane::Actions::TriggerBitriseWorkflowAction.run(
        app_slug: "appslug123",
        workflow_name: "workflow_name",
        commit_hash: "commit_hash",
        build_message: "build_message"
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
          build_message: "build_message"
        )
      end.to raise_error(FastlaneCore::Interface::FastlaneCrash)
    end
  end
end
