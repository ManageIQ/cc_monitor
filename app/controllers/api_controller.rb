class ApiController < ApplicationController

  def show
    result = Project.data(versions)
    respond_to do |format|
      format.json { render :json => result }
    end
  end

  private

  def versions
    params['versions'].to_s.split(",") if params['versions']
  end
end
