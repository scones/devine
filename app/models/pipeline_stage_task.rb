
class PipelineStageTask < ApplicationRecord

  belongs_to :stage, foreign_key: :stage_id, class_name: "PipelineStage", optional: true

  scope :unprocessed, -> { where(state: :created) }
  scope :pipeline_tasks, -> (pipeline_id) {
    joins(stage: :pipeline)
    .where(stages: {pipelines: {id: pipeline_id}})
  }
  scope :processable, -> { where(state: :created) }
  scope :processing, -> { where(state: :processing) }

  after_save :update_parent_state
  before_create :set_number_of_retries
  before_create :set_job_name


  def variables_hash= variables
    self.variables = JSON.dump(variables)
  end

  def variables_hash
    JSON.parse(self.variables) || {}
  end

  def add_variables hash
    tmp = self.variables_hash
    hash.each{|key, value| tmp[key] = value}
    self.variables = tmp
  end

  def self.sync_tasks_with_jobs
    self.processing.each do |task|
      job = k8s_job.fetch_job task
      byebug
    end
  end

  def process
    self.save_state :processing
    job = k8s_job.build_job self
  rescue => exception
    Rails.logger.debug exception.message
    exception.backtrace.each{|trace| Rails.logger.debug trace}
    self.save_state :failed
  end

  def effective_variables
    project_variables = stage.pipeline.project.variables
    pipeline_variables = stage.pipeline.variables_hash
    project_variables.merge(pipeline_variables, self.variables_hash)
  end

  def processable?
    'created' == self.state
  end

  def failed?
    'failed' == self.state
  end


  private


  def save_state state
    self.state = state
    self.save!
  end

  def update_parent_state
    self.stage.update_state
  end

  def k8s_job
    require './lib/kubernetes/job'
    ::Kubernetes::Job
  end

  def set_number_of_retries
    self.number_of_retries = 0
  end

  def set_job_name
    self.job_name = k8s_job.slugify_name "p-#{self.stage.pipeline.id}-t-#{self.id}-#{self.name}-#{self.number_of_retries}"
  end

end
