
module Kubernetes

  class AbstractResource
    DEFAULT_NAMESPACE = 'core'

    protected


    def client
      require_relative 'client'
      Kubernetes::Client.new
    end


    def template type
      require 'k8s-client'
      K8s::Resource.from_file Rails.root.join('lib', 'kubernetes', 'templates', "#{type}.yaml").to_s
    end


    def slugify_name name
      name.parameterize.truncate(253)
    end

  end

end
