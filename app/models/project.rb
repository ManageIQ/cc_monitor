class Project < ActiveRecord::Base
  belongs_to :server

  CATEGORIES_PATH = Rails.root.join("config", "project_categories.yml")
  STATUS_ORDER    = ["success", "rebuilding", "failure", "down"]

  def self.categories
    @categories ||= YAML.load_file(CATEGORIES_PATH)
  end

  def self.data
    Project.order(:version, :db).reverse.each_with_object({}) do |project, hash|
      hash.store_path(project.version, project.db, project.category, project)
      if project.included_in_status?
        hash.store_path(project.version, :status, worst_status(hash.fetch_path(project.version, :status), project.status))
        hash.store_path(:status, worst_status(hash[:status], project.status))
      end
    end
  end

  def self.update_from_xml(server_id, data)
    attributes = {:name => data["name"], :server_id => server_id}
    project    = Project.where(attributes).first || Project.create(attributes.merge(:included_in_status => true))

    project.update_from_xml(data)
  end

  def update_from_xml(data)
    activity, status      = activity_and_status(data["activity"], data["lastBuildStatus"])
    db, version, category = parse_name_parts(data["name"])

    update_attributes(
      :activity   => activity,
      :category   => category,
      :db         => db,
      :last_built => parse_last_built_time(data["lastBuildTime"]),
      :status     => status,
      :last_sha   => data["lastBuildLabel"].to_s.slice(0, 8),
      :version    => version,
      :web_url    => data["webUrl"].to_s,
    )
  end

  private

  def self.worst_status(*args)
    STATUS_ORDER[args.collect { |arg| STATUS_ORDER.index(arg).to_i }.max]
  end
  private_class_method :worst_status

  def parse_last_built_time(time)
    last_built = Time.parse(Time.parse(time).asctime) unless time.blank? # Hack for old cruise control machines with no timezone in string
    last_built.try(:year) == 1970 ? nil : last_built
  end

  def activity_and_status(activity, status)
    activity = activity.to_s.downcase
    activity = "queued" if activity == "unknown"

    status = status.to_s.downcase
    status = "failure"    if status == "unknown"
    status = "rebuilding" if status == "failure" && activity == "building"

    [activity, status]
  end

  def parse_name_parts(name)
    name_parts = name.split("-")
    name_parts.length == 2 ? name_parts.insert(1, "upstream") : name_parts[1] = "#{name_parts[1].gsub("_", ".")}.x"

    name_parts
  end
end
