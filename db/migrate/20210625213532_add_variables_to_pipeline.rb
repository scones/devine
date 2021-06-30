
class AddVariablesToPipeline < ActiveRecord::Migration[6.1]

  def change
    add_column :pipelines, :variables, :text, null: false, default: '{}'
  end

end
