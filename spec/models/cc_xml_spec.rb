#
# Copyright 2012 ManageIQ, Inc.  All rights reserved.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe CcXml do
  XML_WITH_STATUS = <<-EOX
<Projects>
  <Project nextBuildTime="1970-01-01T00:00:00.000000-00:00" activity="CheckingModifications" webUrl="http://cruisecontrol.manageiq.com:3333/projects/pg-lib" lastBuildStatus="Success" lastBuildLabel="34403" name="pg-lib" lastBuildTime="2012-04-04T15:45:20.0000000-00:00" category=""/>
  <Project nextBuildTime="1970-01-01T00:00:00.000000-00:00" activity="Sleeping" webUrl="http://cruisecontrol.manageiq.com:3333/projects/pg-migrations" lastBuildStatus="Failure" lastBuildLabel="34414" name="pg-migrations" lastBuildTime="2012-04-04T15:45:20.0000000-00:00" category=""/>
  <Project nextBuildTime="1970-01-01T00:00:00.000000-00:00" activity="Building" webUrl="http://cruisecontrol.manageiq.com:3333/projects/pg-ui" lastBuildStatus="Failure" lastBuildLabel="34423" name="pg-ui" lastBuildTime="2012-04-04T15:45:20.0000000-00:00" category=""/>
  <Project nextBuildTime="1970-01-01T00:00:00.000000-00:00" activity="Building" webUrl="http://cruisecontrol.manageiq.com:3333/projects/pg-ui_metrics" lastBuildStatus="Success" lastBuildLabel="34389" name="pg-ui_metrics" lastBuildTime="2012-04-04T15:45:20.0000000-00:00" category=""/>
  <Project nextBuildTime="1970-01-01T00:00:00.000000-00:00" activity="Unknown" webUrl="http://cruisecontrol.manageiq.com:3333/projects/pg-vmdb" lastBuildStatus="Success" lastBuildLabel="34403" name="pg-vmdb" lastBuildTime="2012-04-04T15:45:20.0000000-00:00" category=""/>
</Projects>
  EOX

  XML_WITH_VERSIONS = <<-EOX
<Projects>
  <Project nextBuildTime="1970-01-01T00:00:00.000000-00:00" activity="CheckingModifications" webUrl="http://cruisecontrol.manageiq.com:3333/projects/pg-lib" lastBuildStatus="Success" lastBuildLabel="34403" name="pg-lib" lastBuildTime="2012-04-04T15:45:20.0000000-00:00" category=""/>
  <Project nextBuildTime="1970-01-01T00:00:00.000000-00:00" activity="CheckingModifications" webUrl="http://cruisecontrol.manageiq.com:3333/projects/pg-4_0_1-migrations" lastBuildStatus="Success" lastBuildLabel="34414" name="pg-4_0_1-migrations" lastBuildTime="2012-04-04T15:45:20.0000000-00:00" category=""/>
</Projects>
  EOX

  XML_WITH_BAD_TIMES = <<-EOX
<Projects>
  <Project nextBuildTime="1970-01-01T00:00:00.000000-00:00" activity="CheckingModifications" webUrl="http://cruisecontrol.manageiq.com:3333/projects/pg-lib" lastBuildStatus="Success" lastBuildLabel="34403" name="pg-lib" lastBuildTime="2012-04-04T15:45:20.0000000-00:00" category=""/>
  <Project nextBuildTime="1970-01-01T00:00:00.000000-04:00" activity="CheckingModifications" webUrl="http://cruisecontrol.manageiq.com:3333/projects/pg-4_0_1-migrations" lastBuildStatus="Success" lastBuildLabel="34414" name="pg-4_0_1-migrations" lastBuildTime="2012-04-04T15:45:20.0000000-04:00" category=""/>
</Projects>
  EOX

  context "#parse" do
    it "with different statuses" do
      described_class.new(XML_WITH_STATUS).parse.should == [
        {
          :name       => "pg-lib",
          :status     => :success,
          :activity   => :checkingmodifications,
          :url        => "http://cruisecontrol.manageiq.com:3333/projects/pg-lib",
          :last_built => "2012-04-04 15:45:20 -0400",
          :db         => "pg",
          :version    => "trunk",
          :category   => "lib",
        },
        {
          :name       => "pg-migrations",
          :status     => :failure,
          :activity   => :sleeping,
          :url        => "http://cruisecontrol.manageiq.com:3333/projects/pg-migrations",
          :last_built => "2012-04-04 15:45:20 -0400",
          :db         => "pg",
          :version    => "trunk",
          :category   => "migrations",
        },
        {
          :name       => "pg-ui",
          :status     => :rebuilding,
          :activity   => :building,
          :url        => "http://cruisecontrol.manageiq.com:3333/projects/pg-ui",
          :last_built => "2012-04-04 15:45:20 -0400",
          :db         => "pg",
          :version    => "trunk",
          :category   => "ui",
        },
        {
          :name       => "pg-ui_metrics",
          :status     => :success,
          :activity   => :building,
          :url        => "http://cruisecontrol.manageiq.com:3333/projects/pg-ui_metrics",
          :last_built => "2012-04-04 15:45:20 -0400",
          :db         => "pg",
          :version    => "trunk",
          :category   => "ui_metrics",
        },
        {
          :name       => "pg-vmdb",
          :status     => :success,
          :activity   => :queued,
          :url        => "http://cruisecontrol.manageiq.com:3333/projects/pg-vmdb",
          :last_built => "2012-04-04 15:45:20 -0400",
          :db         => "pg",
          :version    => "trunk",
          :category   => "vmdb",
        },
      ]
    end

    it "with different versions" do
      described_class.new(XML_WITH_VERSIONS).parse.should == [
        {
          :name       => "pg-lib",
          :status     => :success,
          :activity   => :checkingmodifications,
          :url        => "http://cruisecontrol.manageiq.com:3333/projects/pg-lib",
          :last_built => "2012-04-04 15:45:20 -0400",
          :db         => "pg",
          :version    => "trunk",
          :category   => "lib",
        },
        {
          :name       => "pg-4_0_1-migrations",
          :status     => :success,
          :activity   => :checkingmodifications,
          :url        => "http://cruisecontrol.manageiq.com:3333/projects/pg-4_0_1-migrations",
          :last_built => "2012-04-04 15:45:20 -0400",
          :db         => "pg",
          :version    => "4.0.1",
          :category   => "migrations",
        },
      ]
    end

    it "with bad times" do
      described_class.new(XML_WITH_BAD_TIMES).parse.should == [
        {
          :name       => "pg-lib",
          :status     => :success,
          :activity   => :checkingmodifications,
          :url        => "http://cruisecontrol.manageiq.com:3333/projects/pg-lib",
          :last_built => "2012-04-04 15:45:20 -0400",
          :db         => "pg",
          :version    => "trunk",
          :category   => "lib",
        },
        {
          :name       => "pg-4_0_1-migrations",
          :status     => :success,
          :activity   => :checkingmodifications,
          :url        => "http://cruisecontrol.manageiq.com:3333/projects/pg-4_0_1-migrations",
          :last_built => "2012-04-04 15:45:20 -0400",
          :db         => "pg",
          :version    => "4.0.1",
          :category   => "migrations",
        },
      ]
    end
  end
end