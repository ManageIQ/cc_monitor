require 'spec_helper'

describe Project do
  let(:data) do
    {
      "name"            => "pg-upstream-vmdb",
      "activity"        => "CheckingModifications",
      "lastBuildStatus" => "Success",
      "lastBuildLabel"  => "f80058377a5b0d2203010aa6d430fd0686063b9e",
      "lastBuildTime"   => "2014-03-21T17:12:36.0000000-0400",
      "webUrl"          => "http://server/projects/pg-upstream-vmdb"
    }
  end

  context ".update_from_xml" do
    it "No Projects" do
      described_class.any_instance.should_receive(:update_from_xml).with(data)

      described_class.update_from_xml(1, data)
    end

    it "Existing Project" do
      described_class.create!(:server_id => 1, :name => "pg-upstream-vmdb")
      described_class.any_instance.should_receive(:update_from_xml).with(data)

      described_class.update_from_xml(1, data)

      expect(described_class.count).to eq(1)
    end
  end

  context "sha_url" do
    it "should use upstream sha url" do
      subject = described_class.create!(
        :server_id => 1,
        :name      => "pg-upstream-vmdb",
        :version   => "upstream",
        :last_sha  => "555aaa5555aaaa")
      expect(subject.dynamic_sha_url).to eq("http://github.com/ManageIQ/manageiq/commit/555aaa55")
    end

    it "should not have no downstream sha url" do
      subject = described_class.create!(
        :server_id => 1,
        :name      => "pg-5.2-vmdb",
        :version   => "5.2",
        :last_sha  => "555aaa5555aaaa")
      expect(subject.dynamic_sha_url).to eq(
        "https://code.engineering.redhat.com/gerrit/gitweb?p=cfme.git;a=commitdiff;h=555aaa5555aaaa")
    end
  end

  context "web_url" do
    it "should support metrics dynamic web url" do
      subject = described_class.create!(
        :server_id => 1,
        :name      => "pg-upstream-vmdb_metrics",
        :category  => "vmdb_metrics",
        :web_url   => "http://s.com/projects/mets",
        :last_sha  => "555aaa5555aaaa")
      expect(subject.dynamic_web_url).to eq("http://s.com/builds/mets/555aaa5555aaaa/artifacts/output/index.html")
    end
    it "should support brakeman dynamic web url" do
      subject = described_class.create!(
        :server_id => 1,
        :name      => "pg-upstream-brakeman",
        :category  => "brakeman",
        :web_url   => "http://s.com/projects/brakeman",
        :last_sha  => "555aaa5555aaaa")
      expect(subject.dynamic_web_url).to eq("http://s.com/builds/brakeman/555aaa5555aaaa/artifacts/brakeman.html")
    end
    it "should support regular dynamic web url" do
      subject = described_class.create!(
        :server_id => 1,
        :name      => "pg-upstream-vmdb",
        :category  => "vmdb",
        :web_url   => "http://www.site.com/",
        :last_sha  => "555aaa5555aaaa")
      expect(subject.dynamic_web_url).to eq("http://www.site.com/")
    end
  end

  context "parse_name_parts" do
    it "should parse upstream name" do
      expect(subject.send(:parse_name_parts, "pg-upstream-vmdb")).to eq(%w(pg upstream vmdb))
    end

    it "should support versions without periods or an x" do
      expect(subject.send(:parse_name_parts, "pg-52x-vmdb")).to eq(%w(pg 5.2.x vmdb))
    end
    it "should support versions with underscores" do
      expect(subject.send(:parse_name_parts, "pg-5_2-vmdb")).to eq(%w(pg 5.2.x vmdb))
    end
  end

  it "#update_from_xml" do
    described_class.update_from_xml(1, data)
    expect(described_class.first.attributes).to include(
      "name"       => "pg-upstream-vmdb",
      "activity"   => "checkingmodifications",
      "category"   => "vmdb",
      "db"         => "pg",
      "last_built" => "2014-03-21 21:12:36.000000",
      "last_sha"   => "f80058377a5b0d2203010aa6d430fd0686063b9e",
      "status"     => "success",
      "version"    => "upstream",
      "web_url"    => "http://server/projects/pg-upstream-vmdb"
    )
  end
end
