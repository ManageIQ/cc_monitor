class Project

  def status
    status = :green
    raw_data.each do |d|
      if d[:status] == :failure
        status = :red
        break
      elsif d[:status] == :rebuilding
        status = :yellow
      end
    end
    status
  end

  def data
    data = raw_data.each_with_object({}) do |d, h|
      h.store_path(d[:version], d[:db], d[:category], d)
    end
    data.sort.reverse
  end

  private

  URLS_PATH = Rails.root.join("config", "project_urls.yml")

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

  def urls
    YAML.load_file(URLS_PATH)
  end

  def get_xml(url)
    require 'open-uri'
    begin
      xml = open(url).read
      raise StandardError if xml.include?("500 Internal Server Error")
      xml
    rescue
      %|<Projects><Project name="Server Down! #{url}" /></Projects>|
    end
  end
end