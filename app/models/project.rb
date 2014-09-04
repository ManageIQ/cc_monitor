class Project < ActiveRecord::Base
  belongs_to :server

  CATEGORIES_PATH = Rails.root.join("config", "project_categories.yml")
  STATUS_ORDER    = %w(success rebuilding failure down)

  def artifacts_directory
    "#{web_url.gsub("/projects", "/builds")}/#{last_sha}/artifacts"
  end

  def presentation_url
    super
      .to_s
      .gsub("$artifacts_directory", artifacts_directory)
      .gsub("$web_url",             web_url)
      .gsub("$short_last_sha",      short_last_sha)
      .gsub("$last_sha",            last_sha)
  end

  def commit_url
    super
      .to_s
      .gsub("$short_last_sha", short_last_sha)
      .gsub("$last_sha",       last_sha)
  end

  def short_last_sha
    last_sha.to_s[0, 8]
  end

  def self.categories
    @categories ||= YAML.load_file(CATEGORIES_PATH)
  end

  def self.data(version = nil)
    version = versions if version.blank?
    build_hash(Project.where(:version => version).order(:version, :db))
  end

  def self.versions
    Project.all.collect(&:version).uniq
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
      :last_sha   => data["lastBuildLabel"].to_s,
      :version    => version,
      :web_url    => data["webUrl"].to_s,
    )
  end

  private

  def self.build_hash(projects)
    projects.reverse.each_with_object({}) do |project, hash|
      hash.store_path("versions", project.version, "dbs", project.db, project.category, project)
      if project.included_in_status?
        hash.store_path("versions", project.version, "status", worst_status(hash.fetch_path(project.version, "status"), project.status))
        hash.store_path("status", worst_status(hash["status"], project.status))
      end
    end
  end
  private_class_method :build_hash

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
    db, version, category = name.split("-") # Project name: pg-upstream-vmdb or pg-52x-lib or pg-5_2-metrics

    category = "vmdb_metrics" if category == "metrics"
    version  = case version
               when "upstream", "downstream" then version
               when /_/                      then "#{version.gsub("_", ".")}.x" # Change "5_2" => "5.2.x"
               else                               version.split("").join(".")   # Change "52x" => "5.2.x"
               end

    [db, version, category]
  end
end
