#
# Copyright 2013 ManageIQ, Inc.  All rights reserved.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Project do
  before do
    raw_data = [{:name=>"pg-vmdb_metrics", :status=>:success, :activity=>:building, :url=>"http://cruisecontrol-metrics.manageiq.com:3333/projects/pg-vmdb_metrics", :last_built=>"2013-01-19 03:19:10 -0500", :db=>"pg", :version=>"trunk", :category=>"vmdb_metrics"}]
    described_class.any_instance.stub(:raw_data => raw_data)
  end

  it "#status" do
    described_class.new.status.should == :green
  end

  it "#data" do
    described_class.new.data.should == [["trunk", {"pg"=>{"vmdb_metrics"=>{:name=>"pg-vmdb_metrics", :status=>:success, :activity=>:building, :url=>"http://cruisecontrol-metrics.manageiq.com:3333/projects/pg-vmdb_metrics", :last_built=>"2013-01-19 03:19:10 -0500", :db=>"pg", :version=>"trunk", :category=>"vmdb_metrics"}}}]]
  end
end