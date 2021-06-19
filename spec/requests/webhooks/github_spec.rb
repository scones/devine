require 'rails_helper'

RSpec.describe "Webhooks::Githubs", type: :request do

  describe "#create" do
    let (:hook_payload) { file_fixture('github-webhook.json').read }
    let (:webhook_secret) { 'bar' }
    let (:headers) { {
      'Content-Type' => 'application/json',
      'HTTP_X_HUB_SIGNATURE_256' => 'sha256=c5004c05007b15d0a0556db48f4c716c7ed78b64fd6954a96352764eea01e3d8',
    } }

    before :each do
      allow(ENV).to receive(:fetch).with('GITHUB_WEBHOOK_TOKEN').and_return(webhook_secret)
    end

    context 'WHEN it IS a verifyable request' do

      let (:webhook_secret) { 'foo' }

      it 'SHOULD respond with no content' do
        post webhooks_github_index_path, params: hook_payload, headers: headers

        expect(response).to have_http_status(:no_content)
      end

      it 'SHOULD create a pipeline' do
        post webhooks_github_index_path, params: hook_payload, headers: headers

        expect(Pipeline.count).to eq 1
      end

      it 'SHOULD autogenerate task names' do
        post webhooks_github_index_path, params: hook_payload, headers: headers

        expect(Pipeline.first.tasks.last.name).to eq 'cleanup-0'
      end

    end

    context 'WHEN it IS NOT a verifyable request' do
      it 'SHOULD respond with unauthorized' do
        post webhooks_github_index_path, params: hook_payload, headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

  end

end
