class PipelineStage < ApplicationRecord

  belongs_to :pipeline, optional: true
  has_many :tasks, foreign_key: :stage_id, class_name: "PipelineStageTask"

  accepts_nested_attributes_for :tasks

  before_validation :ensure_task_names

  # def self.parse_stages stages
  #   validate_stages stages
  #
  #   stages.map{|stage| PipelineStage.new(name: stage) }
  # end

  # def self.validate_stages stages
  #   raise "stages must be an arrray" unless stages.instance_of?(Array)
  #
  #   stages.each{|stage| raise "stages must be an array of string" unless stage.instance_of?(String) }
  # end

  def ensure_task_names
    self.tasks.each_with_index do |task, index|
      task.name ||= "#{self.name}-#{index}"
    end
  end

end
