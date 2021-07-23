
class Project < ApplicationRecord

  DEFAULT_NAMESPACE = 'core'

  has_many :pipelines
  has_many :project_configs

  before_validation :create_slug

  attr_accessor :variables

  def secret_data
    secret = Project.k8s_secret.new project.slug, project.namespace

    secret.data
  end

  def self.build_uuid owner_name, repo_name
    "#{owner_name}-#{repo_name}".parameterize
  end

  def create_pipeline name, params = {}
    Pipeline.create_named_pipeline self, name, params
  end

  def add_to_secret name, value
    add_to_k8s :secret, name, value
  end

  def secret_value name
    secret = Project.k8s_secret.new resource_name
    values = config.data.try(:[], name.to_s)
  end

  def add_to_config name, value
    add_to_k8s :config, name, value
  end

  def add_to_k8s type, name, value
    values = self.public_send(type).data
    values[name.to_s] = value
    self.public_send(type).data = values
  end

  def config_value name
    config.data.try(:[], name.to_s)
  end

  def config
    @config ||= Project.k8s_config.new resource_name, Project.get_namespace(self.uuid)
  end

  def secret
    @secret ||= Project.k8s_secret.new resource_name, Project.get_namespace(self.uuid)
  end

  def resource_name
    "devine-project-#{self.uuid}"
  end

  def self.set_namespace uuid, namespace
    config = k8s_config.new 'devine-config'
    values = config.data
    values['projects'] ||= {}
    values['projects'][uuid] ||= {}
    values['projects'][uuid]['namespace'] = namespace
    config.data = values
  end

  def self.get_namespace uuid
    @@namespace ||= k8s_config.new('devine-config', Project::DEFAULT_NAMESPACE).data.try(:[], 'projects').try(:[], uuid).try(:[], 'namespace') || Project::DEFAULT_NAMESPACE
  end

  def variables
    @variables ||= self.secret.data.merge(self.config.data)
  end


  private


  def create_slug
    self.slug = name.parameterize
  end

  def self.k8s_config
    require './lib/kubernetes/configmap'
    ::Kubernetes::ConfigMap
  end

  def self.k8s_secret
    require './lib/kubernetes/secret'
    ::Kubernetes::Secret
  end

end
