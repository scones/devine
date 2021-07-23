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

ActiveRecord::Schema.define(version: 2021_07_04_133835) do

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
    t.string "job_name"
    t.integer "number_of_retries", default: 0, null: false
  end

  create_table "pipeline_stages", force: :cascade do |t|
    t.integer "pipeline_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "state", default: "created", null: false
    t.index ["pipeline_id", "name"], name: "index_pipeline_stages_on_pipeline_id_and_name"
    t.index ["pipeline_id", "state", "id"], name: "index_pipeline_stages_on_pipeline_id_and_state_and_id"
    t.index ["state"], name: "index_pipeline_stages_on_state"
  end

  create_table "pipelines", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "variables", default: "{}", null: false
    t.integer "project_id", null: false
    t.string "state", default: "created", null: false
    t.index ["project_id"], name: "index_pipelines_on_project_id"
    t.index ["state", "id"], name: "index_pipelines_on_state_and_id"
    t.index ["state"], name: "index_pipelines_on_state"
  end

  create_table "project_configs", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "key", null: false
    t.string "value", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id", "key"], name: "index_project_configs_on_project_id_and_key", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "uuid", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_projects_on_slug", unique: true
  end

end
