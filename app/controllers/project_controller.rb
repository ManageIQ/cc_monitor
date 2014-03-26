class ProjectController < ApplicationController
  def index
    @categories = Project.categories
    @data       = Project.data(versions)

    respond_to do |format|
      format.html
      format.json { render :json => @data }
    end
  end

  private

  def versions
    params['versions'].to_s.split(",") if params['versions']
  end
end
