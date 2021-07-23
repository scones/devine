require_relative 'abstract_resource'

module Kubernetes

  class ConfigMap < AbstractResource

    def initialize name, namespace, data = {}
      name = ConfigMap.slugify_name(name)
      configmap = ConfigMap.resource_from_template 'configmap'
      configmap.metadata.name = name
      configmap.metadata.namespace = namespace

      @configmap = ConfigMap.client.get_resource configmap
    rescue K8s::Error::NotFound => e
      configmap.data = data #.transform_values{|value| JSON.dump(value)}
      @configmap = ConfigMap.client.create_resource configmap
    end

    def data
      return {} unless @configmap

      @data = @configmap.try(:data).to_h #.transform_values{|value| JSON.parse value }
    end

    def data= data
      @data = data
      @configmap.data = data #.transform_values{ |value| JSON.dump(value) }
      @configmap = ConfigMap.client.update_resource @configmap
    end
  end

end
