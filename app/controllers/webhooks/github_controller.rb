
class Webhooks::GithubController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    body = request.body.read
    return render plain: 'unauthorized', :status => :unauthorized unless verify_signature(body)

    params.permit!

    Pipeline.create_named_pipeline 'github-webhook', params.to_h

    head :no_content
  end


  private


  def verify_signature body
    !!Rack::Utils.secure_compare(hashed_body(body), header_signature)
  end

  def slim_commit commit
    {
      hash: commit[:id],
      message: commit[:message],
      timestamp: commit[:timestamp],
      author: commit[:author],
      committer: commit[:committer],
    }
  end

  def slim_repository repository
    {
      id: repository[:id],
      name: repository[:name],
      full_name: repository[:full_name],
      ssh_url: repository[:ssh_url],
      clone_url: repository[:clone_url],
    }
  end

  def header_signature
    request.env.fetch('HTTP_X_HUB_SIGNATURE_256').to_s
  end

  def webhook_secret
    ENV.fetch('GITHUB_WEBHOOK_TOKEN')
  end

  def hashed_body body
    'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), webhook_secret, body)
  end

end
