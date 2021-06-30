
require './lib/kubernetes/job'

class PipelineStageTask < ApplicationRecord

  belongs_to :stage, foreign_key: :stage_id, class_name: "PipelineStage", optional: true

  scope :unprocessed, -> { where(state: :created) }

  def variables_hash= variables
    self.variables = JSON.dump(variables)
  end

  def variables_hash
    JSON.parse(self.variables)
  end

  def add_variables hash
    tmp = self.variables_hash
    hash.each{|key, value| tmp[key] = value}
    self.variables = tmp
  end

  def process
    self.save_state :process

    job = Kubernetes::Job.create_and_wait task

    self.save_state :done
  rescue => exception
    self.save_state :failed
  end


  private


  def save_state state
    self.state = state
    self.save!
  end
end
