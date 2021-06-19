# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_06_19_080609) do

  create_table "pipeline_stage_tasks", force: :cascade do |t|
    t.integer "stage_id", null: false
    t.string "name", null: false
    t.string "image"
    t.text "script"
    t.string "state", default: "created", null: false
    t.text "output"
    t.text "variables", default: "null", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "pipeline_stages", force: :cascade do |t|
    t.integer "pipeline_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pipeline_id", "name"], name: "index_pipeline_stages_on_pipeline_id_and_name"
  end

  create_table "pipelines", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index "\"state\"", name: "index_pipelines_on_state"
  end

end
