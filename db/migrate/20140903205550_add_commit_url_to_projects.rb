class AddCommitUrlToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :commit_url, :string
  end
end
