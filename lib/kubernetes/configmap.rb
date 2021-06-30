require_relative 'abstract_resource'

module Kubernetes

  class ConfigMap < AbstractResource

    def initialize name, namespace, data = {}
      name = slugify_name(name)
      configmap = template 'configmap'
      configmap.metadata.name = name
      configmap.metadata.namespace = namespace

      @configmap = client.get_resource configmap
    rescue K8s::Error::NotFound => e
      data.each do |name, value|
        configmap.spec.data[name] = JSON.dump(value)
      end

      @configmap = client.create_resource configmap
    end

    def data
      @configmap.data
    end

    def data= data
      data.each do |key, value|
        @configmap.spec.data[key] = JSON.dump(value)
      end
      client.patch_resource @configmap
    end
  end

end
