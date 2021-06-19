class CreatePipelineStages < ActiveRecord::Migration[6.1]
  def change
    create_table :pipeline_stages do |t|
      t.integer :pipeline_id, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :pipeline_stages, [:pipeline_id, :name]
  end
end
