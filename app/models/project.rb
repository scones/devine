
class Project < ApplicationRecord

  has_many :pipelines
  has_many :project_configs

  before_validation :create_slug

  def secret_data
    require './lib/kubernetes/secret'
    secret = Kubernetes::Secret.new project.slug, project.namespace

    secret.data
  end

  def self.build_uuid owner_name, repo_name
    "#{owner_name}-#{repo_name}".parameterize
  end

  def create_pipeline name, params = {}
    Pipeline.create_named_pipeline self, name, params
  end

  def add_to_secret name, value
    config = Kubernetes::Secret.new resource_name
    values = config.data
    values[name.to_s] = value
    config.data = values
  end

  def secret_value name
    config = Kubernetes::Secret.new resource_name
    values = config.data.try(:[], name.to_s)
  end

  def add_to_config name, value
    config = Kubernetes::Config.new resource_name
    values = config.data
    values[name.to_s] = value
    config.data = values
  end

  def config_value name
    config = Kubernetes::Config.new resource_name
    values = config.data.try(:[], name.to_s)
  end

  def resource_name
    "devine-#{self.name}-#{self.uuid}"
  end

  def self.set_namespace uuid, namespace
    config = Kubernetes::Config.new 'devine-config'
    values = config.data
    values['projects'] ||= {}
    values['projects'][uuid] ||= {}
    values['projects'][uuid]['namespace'] = namespace
    config.data = values
  end

  def self.get_namespace uuid, namespace
    config = Kubernetes::Config.new 'devine-config'
    config.data.try(:[], 'projects').try(:[], uuid).try(:[], 'namespace') || Project::DEFAULT_NAMESPACE
  end


  private


  def create_slug
    self.slug = name.parameterize
  end

end
