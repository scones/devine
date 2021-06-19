require 'pretty_api'

class Pipeline < ApplicationRecord

  has_many :stages, foreign_key: :pipeline_id, class_name: "PipelineStage"
  has_many :tasks, through: :stages

  accepts_nested_attributes_for :stages

  # def variables= variables
  #   super(variables.to_json)
  # end

  def self.create_named_pipeline name, variables = {}
    github_pipeline_path = File.join(Rails.root, 'app', 'pipelines', "#{name}.yaml")
    Pipeline.create_from_file github_pipeline_path, variables
  end

  def self.create_from_file file_path, variables = {}
    yaml = File.read file_path
    Pipeline.create_from_yaml yaml, variables
  end

  def self.create_from_yaml yaml, variables = {}
    params = YAML.load(yaml).deep_symbolize_keys

    # params[:variables] ||= {}
    # params[:variables].merge!(variables)

    pipeline_params = PrettyApi.with_nested_attributes params.deep_symbolize_keys, stages: [:tasks]
    Pipeline.create! pipeline_params
  end

  # def self.parse_sections sections, variables = {}
  #   pipeline = Pipeline.new
  #
  #   sections.each do |key, value|
  #     case key
  #     when 'stages'
  #       pipeline_stages = PipelineStage.parse_stages(value)
  #     else
  #       if 'task' == value.try(:[], 'type')
  #         pipeline.tasks << PipelineTask.parse_task(value)
  #       else
  #         pipeline.templates << PipelineTemplates.parse_template(value)
  #       end
  #     end
  #   end
  # end

  # def self.validate_sections sections
  #   raise "invalid pipeline format" unless sections.instance_of?(Hash)
  # end

end
