
module Github
  GITHUB_CREATE_ACCESS_TOKEN_URI="https://github.com/login/oauth/access_token"

  class Client

    def initialize url, credentials = {}
      require 'uri'

      @uri = URI(url)
      @credentials = credentials
    end

    def clone_into_dir path
      return clone_with_token_into_dir path
    end

    def clone_with_token_into_dir path
      @uri.user = @credentials[:user]
      @uri.password = @credentials[:password]
      Git.clone(@uri.to_s, "build", path: path)
    end

    def self.clone_project_from_pipeline pipeline_id
      pipeline = Pipeline.find pipeline_id
      project = pipeline.project
      client = Github::Client.new project.config.data[:repo_uri], user: project.secret.data['access_token'], password: 'x-oauth-token'
      client.clone_with_token_into_dir pipeline.working_directory(ENV['DEVINE_WORKING_DIRECTORY'])
    end

  end

end
