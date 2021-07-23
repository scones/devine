require_relative 'abstract_resource'

module Kubernetes

  class Secret < AbstractResource

    def initialize name, namespace, data = {}
      name = Secret.slugify_name(name)
      secret = Secret.resource_from_template 'secret'
      secret.metadata.name = name
      secret.metadata.namespace = namespace

      @secret = Secret.client.get_resource secret
    rescue K8s::Error::NotFound => e
      require 'base64'

      secret.data = data.transform_values{|value| Base64.strict_encode64 value }
      @secret = Secret.client.create_resource secret
    end

    def data
      return {} unless @secret

      require 'base64'
      @data ||= @secret.try(:data).to_h.transform_values{|value| Base64.strict_decode64 value}
    end

    def data= data
      require 'base64'
      @data = data
      @secret.data = data.each{ |key, value| data[key] = Base64.strict_encode64 value }
      @secret = Secret.client.update_resource @secret
    end
  end

end
