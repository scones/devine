
class PipelineStage < ApplicationRecord

  belongs_to :pipeline, optional: true
  has_many :tasks, foreign_key: :stage_id, class_name: "PipelineStageTask"

  accepts_nested_attributes_for :tasks

  before_validation :ensure_task_names

  after_save :update_parent_state

  scope :failed, -> { where(state: :failed) }
  scope :processable, -> { where(state: [:created, :processing]) }


  def failed?
    'failed' == self.state
  end

  def processable?
    ['created', 'processing'].include?(self.state)
  end

  def ensure_task_names
    self.tasks.each_with_index do |task, index|
      task.name ||= "#{self.name}-#{index}"
    end
  end

  def update_state
    children_states = tasks.map(&:state).map(&:to_sym)
    self.state = StateTree.determine_state_from_children children_states
    self.save!
  end

  def update_parent_state
    self.pipeline.update_state
  end

end
