#
# Copyright 2013 ManageIQ, Inc.  All rights reserved.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Project do
  context "when server is up" do
    before do
      raw_data = [{
        :name       => "pg-vmdb_metrics",
        :status     => :success,
        :activity   => :building,
        :url        => "http://cruisecontrol-metrics.manageiq.com:3333/projects/pg-vmdb_metrics",
        :last_built => "2013-01-19 03:19:10 -0500",
        :version    => "trunk",
        :db         => "pg",
        :category   => "vmdb_metrics"
      }]
      described_class.any_instance.stub(:raw_data => raw_data)
    end

    it "#status" do
      described_class.new.status.should == :green
    end
    pending "#status - :rebuilding"
    pending "#status - :failure"

    it "#data" do
      described_class.new.data.should == [
        ["trunk",
          {
            "pg" => {
              "vmdb_metrics" => {
                :name       => "pg-vmdb_metrics",
                :status     => :success,
                :activity   => :building,
                :url        => "http://cruisecontrol-metrics.manageiq.com:3333/projects/pg-vmdb_metrics",
                :last_built => "2013-01-19 03:19:10 -0500",
                :version    => "trunk",
                :db         => "pg",
                :category   => "vmdb_metrics"
              }
            }
          }
        ]
      ]
    end
  end

  context "when server is down" do
    shared_examples_for "server is down" do
      it "#data" do
        described_class.new.data.should == [
          ["",
            {
              "http://cruisecontrol/XmlStatusReport.aspx" => {
                nil => {
                  :name       => nil,
                  :status     => :down,
                  :activity   => nil,
                  :url        => "http://cruisecontrol/XmlStatusReport.aspx",
                  :last_built => nil,
                  :version    => "",
                  :db         => "http://cruisecontrol/XmlStatusReport.aspx",
                  :category   => nil
                }
              }
            }
          ]
        ]
      end

      it "#status" do
        described_class.new.status.should == :gray
      end
    end

    before do
      described_class.any_instance.stub(:urls => ["http://cruisecontrol/XmlStatusReport.aspx"])
    end

    context "and raises an exception" do
      before do
        described_class.any_instance.stub(:open).and_raise(StandardError)
      end

      include_examples "server is down"
    end

    context "and returns a 500 error" do
      before do
        described_class.any_instance.stub(:open => mock(:read => "500 Internal Server Error"))
      end

      include_examples "server is down"
    end
  end
end