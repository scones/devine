
class CreateProjectConfigs < ActiveRecord::Migration[6.1]

  def change
    create_table :project_configs do |t|
      t.integer :project_id, null: false

      t.string :key, null: false
      t.string :value, null: false

      t.timestamps
    end

    add_index :project_configs, [:project_id, :key], unique: true
  end

end
