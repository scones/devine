require 'pretty_api'
require 'state_tree'

class Pipeline < ApplicationRecord

  belongs_to :project
  has_many :stages, foreign_key: :pipeline_id, class_name: "PipelineStage"
  has_many :tasks, through: :stages

  accepts_nested_attributes_for :stages

  scope :pipeline_tasks, -> (pipeline_id) { includes(stages: :tasks ).where(id: pipeline_id) }
  scope :processable, -> { where(state: [:created, :processing]) }

  def variables_hash= variables
    self.variables = JSON.dump(variables)
  end

  def variables_hash
    JSON.parse(self.variables)
  end

  def add_variables hash
    tmp = self.variables_hash
    hash.each{|key, value| tmp[key] = value}
    self.variables_hash = tmp
  end

  def self.create_named_pipeline project, name, variables = {}
    github_pipeline_path = File.join(Rails.root, 'app', 'pipelines', "#{name}.yaml")
    Pipeline.create_from_file project, github_pipeline_path, variables
  end

  def self.create_from_file project, file_path, variables = {}
    yaml = File.read file_path
    Pipeline.create_from_yaml project, yaml, variables
  end

  def self.create_from_yaml project, yaml, variables = {}
    params = YAML.load(yaml).deep_symbolize_keys

    pipeline_params = PrettyApi.with_nested_attributes params.deep_symbolize_keys, stages: [:tasks]
    pipeline_params[:project_id] = project.id
    pipeline = Pipeline.create! pipeline_params
    pipeline.add_variables variables.merge(PIPELINE_ID: pipeline.id)
    pipeline.save!
  end

  def prepare base_directory
    require 'fileutils'
    FileUtils.mkdir_p working_directory(base_directory)
    v  = self.variables
  end

  def run
  end

  def clean
  end

  def working_directory base_directory
     base_directory + "/projects/#{project.slug}/pipelines/#{pipeline.id}" + '/build'
  end

  def update_state
    children_states = self.stages.map(&:state).map(&:to_sym)
    self.state = StateTree.determine_state_from_children children_states
    self.save!
  end

  def self.processable_tasks
    stages = self.processable
      .map(&:stages)
      .reject{|pipeline_stages| pipeline_stages.select(&:failed?).count > 0 }
      .map{|pipeline_stages| pipeline_stages.select(&:processable?)}
      .map{|pipeline_stages| pipeline_stages.sort_by{|stage| stage.id } }
      .map(&:first)
      .reject(&:nil?)
      .map(&:tasks)
      .reject{|stage_tasks| stage_tasks.select(&:failed?).count > 0 }
      .map{|stage_tasks| stage_tasks.select(&:processable?)}
      .map{|stage_tasks| stage_tasks.sort_by{|task| task.id } }
      .map(&:first)
      .reject(&:nil?)
  end


end
