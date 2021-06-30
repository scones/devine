class AddProjectIdToPipeline < ActiveRecord::Migration[6.1]
  def change
    add_column :pipelines, :project_id, :integer, null: false
    add_index :pipelines, :project_id
  end
end
