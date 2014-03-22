class CreateProjects < ActiveRecord::Migration
  def up
    create_table :projects do |t|
      t.string  :name
      t.string  :activity
      t.boolean :aggregate_status
      t.string  :category
      t.string  :db
      t.string  :last_built
      t.string  :last_sha
      t.string  :status
      t.string  :version
      t.string  :web_url
      t.references :server

      t.timestamps
    end
  end

  def down
    drop_table :projects
  end
end
