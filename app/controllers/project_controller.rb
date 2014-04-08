class ProjectController < ApplicationController
  def index
    @categories = Project.categories
    @data       = Project.data
    @num_rows   = num_rows
  end

  def api
    versions, version, status = path_arguments
    if versions
      if version
        if status
          render :json => Project.data(version)[status]
        else
          render :json => Project.data(version)
        end
      else
        render :json => Project.versions
      end
    elsif status
      render :json => Project.data[status]
    else
      render :json => Project.data
    end
  end

  private

  def path_arguments
    @raw_path ||= begin
      path_array = request.fullpath.split("api").last.split("/").delete_blanks
      status     = path_array.delete("status")
      versions   = path_array.delete("versions")
      version    = path_array.first
      [versions, version, status]
    end
  end

  def num_rows
    @data["versions"].inject(0) { |count, (_, v)| count + v["dbs"].keys.length }
  end
end
