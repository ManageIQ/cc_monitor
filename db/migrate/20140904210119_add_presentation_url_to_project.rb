class AddPresentationUrlToProject < ActiveRecord::Migration
  def change
    add_column :projects, :presentation_url, :string
  end
end
