
module Kubernetes

  class Client
    @@client = nil

    def initialize
      foo = @@client
      foo ||= if File.exist? '/var/run/secrets/kubernetes.io/serviceaccount/token'
        K8s::Client.in_cluster_config
      else
        K8s::Client.config K8s::Config.load_file('~/.kube/config')
      end
      @@client = foo
    end

    def method_missing(name, *args, &block)
      @@client.public_send(name, *args, &block)
    end

  end

end
