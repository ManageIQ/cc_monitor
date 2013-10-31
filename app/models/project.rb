class Project

  def status
    @status ||= begin
      status = :green
      filtered_raw_data.each do |d|
        status = worst_status(status, RAW_STATUS_TO_STATUS[d[:status]])
      end
      status
    end
  end

  def data
    @data ||= begin
      data = filtered_raw_data.each_with_object({}) do |d, h|
        h.store_path(d[:version], d[:db], d[:category], d)
      end
      data.sort.reverse
    end
  end

  def categories
    @categories ||= YAML.load_file(CATEGORIES_PATH)
  end

  private

  CATEGORIES_PATH = Rails.root.join("config", "project_categories.yml")
  URLS_PATH       = Rails.root.join("config", "project_urls.yml")

  def raw_data
    @raw_data ||= begin
      data = []

      CcXml # Eager load the constant so that it works with threading.
      threads = []
      urls.each do |url|
        threads << Thread.new { data << CcXml.new(get_xml(url)).parse }
      end
      threads.map(&:join)

      data.flatten
    end
  end

  def filtered_raw_data
    @filtered_raw_data ||= raw_data.select { |d| d[:category].nil? || categories.include?(d[:category]) }
  end

  def urls
    @urls ||= YAML.load_file(URLS_PATH)
  end

  def get_xml(url)
    server_down = false
    xml = nil

    require 'open-uri'
    begin
      xml = open(url, :read_timeout => 30).read
      server_down = true if xml.include?("500 Internal Server Error")
    rescue
      server_down = true
    end
    xml = CcXml.server_down_xml(url) if server_down

    xml
  end

  STATUSES = [:green, :yellow, :red, :gray]

  RAW_STATUS_TO_STATUS = Hash.new(:green).merge(
    :down       => :gray,
    :failure    => :red,
    :rebuilding => :yellow
  )

  def worst_status(x, y)
    worst_status_index = [STATUSES.index(x), STATUSES.index(y)].max
    STATUSES[worst_status_index]
  end
end