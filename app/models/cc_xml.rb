#
# Copyright 2012 ManageIQ, Inc.  All rights reserved.
#
include ActionView::Helpers::DateHelper

class CcXml
  def self.server_down_xml(url)
    %|<Projects><Project webUrl="#{url}" lastBuildStatus="down" /></Projects>|
  end

  attr_accessor :xml

  def initialize(xml)
    @xml = xml
  end

  def parse
    doc = Nokogiri::XML(xml) { |config| config.noblanks }
    doc.children.first.children.collect do |c|
      parsed = {
        :name              => c["name"],
        :last_build_status => c["lastBuildStatus"] && c["lastBuildStatus"].to_s.downcase.to_sym,
        :last_build_time   => c["lastBuildTime"],
        :last_build_label  => c["lastBuildLabel"],
        :activity          => c["activity"]        && c["activity"].to_s.downcase.to_sym,
        :web_url           => c["webUrl"]          && c["webUrl"].to_s
      }
      convert_data(parsed)
    end
  end

  private

  def convert_data(parsed)
    activity = parsed[:activity]
    activity = :queued if parsed[:activity] == :unknown

    status = parsed[:last_build_status]
    status = :failure if status == :unknown
    status = :rebuilding if status == :failure && activity == :building

    name_parts =
      if status == :down
        server_down_name_parts(parsed[:web_url])
      else
        parse_name_parts(parsed[:name])
      end

    last_built = Time.parse(Time.parse(parsed[:last_build_time]).asctime) unless parsed[:last_build_time].blank?  # Hack for old cruise control machines with no timezone in string
    last_built = nil if last_built.try(:year) == 1970

    {
      :name       => parsed[:name],
      :status     => status,
      :activity   => activity,
      :url        => parsed[:web_url],
      :last_built => last_built,
      :last_sha   => parsed[:last_build_label].to_s.slice(0, 8)
    }.merge(name_parts)
  end

  def parse_name_parts(name)
    db, version, category = name.split("-")

    if category.nil?
      category = version
      version  = "upstream"
    else
      version  = "#{version.gsub("_", ".")}.x"
    end

    {
      :version  => version,
      :db       => db,
      :category => category,
    }
  end

  def server_down_name_parts(url)
    {
      :version  => "",
      :db       => url,
      :category => nil,
    }
  end
end