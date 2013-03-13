class CcMonitorController < ApplicationController
  def index
    p       = Project.new
    @data   = p.data
    @status = p.status
  end
end