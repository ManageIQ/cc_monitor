require 'spec_helper'

describe Server do
  let(:server) { Server.create!(:url => "http://server/XmlStatusReport.aspx") }

  it ".refresh" do
    server

    described_class.any_instance.should_receive(:refresh).once
    described_class.refresh
  end

  context "#refresh" do
    pending "Server up" do
    end

    it "Server down raises error" do
      server
      Project.create!(:server_id => server.id)

      described_class.any_instance.should_receive(:open).and_raise(StandardError)

      server.refresh

      expect(Project.first.status).to eq("down")
    end

    it "Server down returns 500" do
      server
      Project.create!(:server_id => server.id)

      described_class.any_instance.should_receive(:open).and_return("response with 500 Internal Server Error")

      server.refresh

      expect(Project.first.status).to eq("down")
    end
  end
end
