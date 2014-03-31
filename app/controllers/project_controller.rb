class ProjectController < ApplicationController
  def index
    @categories = Project.categories
    @data       = Project.data
    @num_rows   = num_rows
  end

  def api
    @data = Project.data(version)
    render :json => (@data[key] || @data)
  end

  private

  def version
    raw_path.last
  end

  def key
    raw_path.first
  end

  def raw_path
    @raw_path ||= begin
      path_array = request.fullpath.split("api").last.split("/").delete_blanks
      [path_array.delete("status"), path_array.first]
    end
  end

  def num_rows
    @data["versions"].inject(0) { |count, (_, v)| count + v["dbs"].keys.length }
  end
end
