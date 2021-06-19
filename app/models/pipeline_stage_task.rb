class PipelineStageTask < ApplicationRecord

  belongs_to :stages, foreign_key: :stage_id, class_name: "PipelineStage", optional: true



end
