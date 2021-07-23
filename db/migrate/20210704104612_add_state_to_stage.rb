class AddStateToStage < ActiveRecord::Migration[6.1]
  def change
    add_column :pipeline_stages, :state, :string, null: false, default: :created
    add_index :pipeline_stages, :state
    add_index :pipeline_stages, [:pipeline_id, :state, :id]
  end
end
