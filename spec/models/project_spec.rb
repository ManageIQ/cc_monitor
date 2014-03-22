require 'spec_helper'

describe Project do
  let(:data) do
    {
      "name"            => "pg-vmdb",
      "activity"        => "CheckingModifications",
      "lastBuildStatus" => "Success",
      "lastBuildLabel"  => "f80058377a5b0d2203010aa6d430fd0686063b9e",
      "lastBuildTime"   => "2014-03-21T17:12:36.0000000-0400",
      "webUrl"          => "http://server/projects/pg-vmdb"
    }
  end

  context ".update_from_xml" do
    it "No Projects" do
      described_class.any_instance.should_receive(:update_from_xml).with(data)

      described_class.update_from_xml(1, data)
    end

    it "Existing Project" do
      described_class.create!(:server_id => 1, :name => "pg-vmdb")
      described_class.any_instance.should_receive(:update_from_xml).with(data)

      described_class.update_from_xml(1, data)

      expect(described_class.count).to eq(1)
    end
  end

  it "#update_from_xml" do
    described_class.update_from_xml(1, data)

    expect(described_class.first.name).to       eq("pg-vmdb")
    expect(described_class.first.activity).to   eq("checkingmodifications")
    expect(described_class.first.category).to   eq("vmdb")
    expect(described_class.first.db).to         eq("pg")
    expect(described_class.first.last_built).to eq("2014-03-21 21:12:36.000000")
    expect(described_class.first.last_sha).to   eq("f8005837")
    expect(described_class.first.status).to     eq("success")
    expect(described_class.first.version).to    eq("upstream")
    expect(described_class.first.web_url).to    eq("http://server/projects/pg-vmdb")
  end
end
