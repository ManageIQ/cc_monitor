class ProjectController < ApplicationController
  def index
    @categories = Project.categories
    @data       = Project.data(versions)
    @num_rows   = num_rows

    respond_to do |format|
      format.html
      format.json { render :json => @data }
    end
  end

  private

  def versions
    params['versions'].to_s.split(",") if params['versions']
  end

  def num_rows
    @data["versions"].inject(0) { |count, (_, v)| count + v["dbs"].keys.length }
  end
end
