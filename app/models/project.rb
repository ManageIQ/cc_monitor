class Project < ActiveRecord::Base
  CATEGORIES_PATH = Rails.root.join("config", "project_categories.yml")

  def self.categories
    @categories ||= YAML.load_file(CATEGORIES_PATH)
  end

  def self.update_from_xml(server_id, data)
    attributes = {:name => data["name"], :server_id => server_id}
    project    = Project.where(attributes).first || Project.create(attributes.merge(:aggregate_status => true))

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
      :status     => status.to_s,
      :last_sha   => data["lastBuildLabel"].to_s.slice(0, 8),
      :version    => version,
      :web_url    => data["webUrl"].to_s,
    )
  end

  private

  def parse_last_built_time(time)
    last_built = Time.parse(Time.parse(time).asctime) unless time.blank? # Hack for old cruise control machines with no timezone in string
    last_built.try(:year) == 1970 ? nil : last_built
  end

  def activity_and_status(activity, status)
    activity = activity.to_s.downcase.to_sym
    activity = :queued if activity == :unknown

    status = status.to_s.downcase.to_sym
    status = :failure    if status == :unknown
    status = :rebuilding if status == :failure && activity == :building

    [activity, status]
  end

  def parse_name_parts(name)
    name_parts = name.split("-")
    name_parts.length == 2 ? name_parts.insert(1, "upstream") : name_parts[1] = "#{name_parts[1].gsub("_", ".")}.x"

    name_parts
  end
end
