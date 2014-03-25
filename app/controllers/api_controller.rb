
class ApiController < ApplicationController

  def show
    versions = params['versions'] ? params['versions'].split(",") : []
    result = versions.blank? ? Project.data : Project.data.select { |key| versions.include?(key) }
    respond_to do |format|
      format.json { render :json => result }
    end
  end

end
