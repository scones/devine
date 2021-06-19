class CreatePipelineStageTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :pipeline_stage_tasks do |t|
      t.integer :stage_id, null: false
      t.string :name, null: false

      t.string :image, null: true
      t.text :script, null: true

      t.string :state, null: false, default: :created

      t.text :output, null: true

      t.text :variables, null: false, default: 'null'

      t.timestamps
    end
  end
end
