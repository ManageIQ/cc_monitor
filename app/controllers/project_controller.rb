class ProjectController < ApplicationController
  def index
    @categories = Project.categories
    @data       = Project.data
  end
end
