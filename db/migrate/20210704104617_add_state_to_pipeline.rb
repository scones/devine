class AddStateToPipeline < ActiveRecord::Migration[6.1]
  def change
    add_column :pipelines, :state, :string, null: false, default: :created
    add_index :pipelines, [:state, :id]
  end
end
