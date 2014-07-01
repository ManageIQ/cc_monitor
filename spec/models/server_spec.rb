require 'spec_helper'

describe Server do
  let(:server) { Server.create!(:url => "http://server/XmlStatusReport.aspx") }
  let(:project) { Project.create!(:server => server, :name => "pg-migrations") }

  it ".refresh" do
    server

    described_class.any_instance.should_receive(:refresh).once
    described_class.refresh
  end

  context "#refresh" do
    it "Server up" do
      xml_data = %(<Projects>
  <Project name="pg-migrations" category="" activity="CheckingModifications" lastBuildStatus="Success"
  lastBuildLabel="5050505050505050505050505050505050505050" lastBuildTime="2014-06-20T15:17:36.0000000-0400"
  nextBuildTime="1970-01-01T00:00:00.000000-00:00" webUrl="http://cc.com/projects/pg-migrations"/>
</Projects>)
      expect_any_instance_of(described_class).to receive(:open).and_return(StringIO.new(xml_data))
      project.server.refresh
      expect(project.reload.status).to eq("success")
      expect(project.attributes).to include(
        "last_sha" => "5050505050505050505050505050505050505050",
        "web_url"  => "http://cc.com/projects/pg-migrations"
      )
    end

    it "should mark server down if server raises error" do
      expect_any_instance_of(described_class).to receive(:open).and_raise(StandardError)
      project.server.refresh
      expect(project.reload.status).to eq("down")
    end

    it "should mark server down if server returns 500" do
      xml_data = "<Projects>response with 500 Internal Server Error</Projects>"
      expect_any_instance_of(described_class).to receive(:open).and_return(StringIO.new(xml_data))
      project.server.refresh
      expect(project.reload.status).to eq("down")
    end
  end
end
