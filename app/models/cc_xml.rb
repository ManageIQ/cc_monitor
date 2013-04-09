#
# Copyright 2012 ManageIQ, Inc.  All rights reserved.
#
include ActionView::Helpers::DateHelper

class CcXml
  attr_accessor :xml

  def initialize(xml)
    @xml = xml
  end

  def parse
    doc = Nokogiri::XML(xml) { |config| config.noblanks }
    doc.children.first.children.collect do |c|
      parsed = {
        :name              => c["name"],
        :last_build_status => c["lastBuildStatus"].to_s.downcase.to_sym,
        :last_build_time   => c["lastBuildTime"],
        :last_build_label  => c["lastBuildLabel"],
        :activity          => c["activity"].to_s.downcase.to_sym,
        :web_url           => c["webUrl"].to_s.downcase
      }
      convert_data(parsed)
    end
  end

  private

  def convert_data(parsed)
    status = parsed[:last_build_status]
    if status.blank?
      status = :down
    elsif status == :failure && parsed[:activity] == :building
      status = :rebuilding
    end

    name_parts = parse_name(parsed[:name])

    last_built =  begin
                    Time.parse(Time.parse(parsed[:last_build_time]).asctime).to_s  # Hack for old cruise control machines with no timezone in string
                  rescue
                  end

    {
      :name       => parsed[:name],
      :status     => status,
      :activity   => parsed[:activity],
      :url        => parsed[:web_url],
      :last_built => last_built,
    }.merge(name_parts)
  end

  def parse_name(name)
    db, version, category = name.split("-")

    if category.nil?
      category = version
      version  = "trunk"
    end

    {
      :db       => db,
      :version  => version.gsub("_", "."),
      :category => category,
    }
  end
end