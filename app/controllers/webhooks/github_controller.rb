class Webhooks::GithubController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    http_headers = request.headers.env.select do |k, _|
      k.downcase.start_with?('http') ||
      k.in?(ActionDispatch::Http::Headers::CGI_VARIABLES)
    end

    Rails.logger.info http_headers.inspect
    Rails.logger.info params.inspect

    head :no_content
  end

end
