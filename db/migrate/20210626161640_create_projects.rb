
class CreateProjects < ActiveRecord::Migration[6.1]

  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :uuid, null: false

      t.timestamps
    end

    add_index :projects, :slug, unique: true
  end

end
