
class CreatePipelines < ActiveRecord::Migration[6.1]
  def change
    create_table :pipelines do |t|

      t.timestamps
    end
    add_index :pipelines, :state
  end
end
