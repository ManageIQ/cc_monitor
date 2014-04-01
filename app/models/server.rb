class Server < ActiveRecord::Base
  has_many :projects

  def self.refresh
    all.each(&:refresh)
  end

  def refresh
    update_projects
  end

  private

  def raw_xml
    require 'open-uri'

    xml = open(url, :read_timeout => 30).read
    server_status = xml.include?("500 Internal Server Error") ? :down : :up
    [server_status, xml]
  rescue
    [:down, nil]
  end

  def update_projects
    server_status, xml = raw_xml

    if server_status == :down
      projects.update_all(:status => "down", :activity => "down")
      return
    end

    doc = Nokogiri::XML(xml) { |config| config.noblanks }
    doc.children.first.children.collect do |data|
      Project.update_from_xml(id, data)
    end
  end
end
