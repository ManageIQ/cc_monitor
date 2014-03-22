class ProjectController < ApplicationController
  def index
    @categories = Project.categories
    @data       = data
  end

  private

  STATUS = ["green", "yellow", "red", "gray"]

  STATUS_TRANSLATIONS = Hash.new("green").merge(
    "down"       => "gray",
    "failure"    => "red",
    "rebuilding" => "yellow"
  )

  def worst_status(*args)
    worst = args.collect do |arg|
      STATUS.index(arg) || STATUS.index(STATUS_TRANSLATIONS[arg]).to_i
    end.max

    STATUS[worst]
  end

  def data
    Project.order(:version, :db).reverse.each_with_object({}) do |project, hash|
      hash.store_path(project.version, project.db, project.category, project)
      if project.aggregate_status
        hash.store_path(project.version, :status, worst_status(hash.fetch_path(project.version, :status), project.status))
        hash.store_path(:status, worst_status(hash[:status], project.status))
      end
    end
  end
end
