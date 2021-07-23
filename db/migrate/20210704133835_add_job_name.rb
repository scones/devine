
class AddJobName < ActiveRecord::Migration[6.1]
  def change
    add_column :pipeline_stage_tasks, :job_name, :string
    add_column :pipeline_stage_tasks, :number_of_retries, :integer, null: false, default: 0
  end
end
