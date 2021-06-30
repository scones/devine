require_relative 'abstract_resource'

module Kubernetes

  class Secret < AbstractResource

    def initialize name, namespace, data = {}
      name = slugify_name(name)
      secret = template 'secret'
      secret.metadata.name = name
      secret.metadata.namespace = namespace

      @secret = client.get_resource secret
    rescue K8s::Error::NotFound => e
      require 'base64'

      data.each do |name, value|
        secret.spec.data[name] = Base64.strict_encode64 value
      end

      @secret = client.create_resource secret
    end

    def data
      return {} unless @secret

      require 'base64'

      @data ||= @secret.data.inject({}) do |target, (key, value)|
        target[key] = Base64.strict_decode64 value
        target
      end
    end

    def data= data
      require 'base64'
      data.each do |name, value|
        @secret.spec.data[name] = Base64.strict_encode64 value
      end
      client.patch_resource @secret
    end

  end

end
