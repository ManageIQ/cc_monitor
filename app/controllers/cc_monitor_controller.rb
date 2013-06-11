class CcMonitorController < ApplicationController
  def index
    p           = Project.new
    @categories = p.categories
    @data       = p.data
    @status     = p.status
  end
end