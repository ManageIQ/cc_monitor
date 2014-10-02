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

  context "#commit_url" do
    it "should allow substituting $short_last_sha" do
      subject = described_class.create!(
        :last_sha   => "a7bc38b1010cf61019d78b65e09215ddc6fac42d",
        :commit_url => "http://github.com/Organization/repo/commit/$short_last_sha"
      )
      expect(subject.commit_url).to eq("http://github.com/Organization/repo/commit/a7bc38b1")
    end

    it "should allow substituting $last_sha" do
      subject = described_class.create!(
        :last_sha   => "a7bc38b1010cf61019d78b65e09215ddc6fac42d",
        :commit_url => "https://gerrit_server/gerrit/gitweb?p=repo.git;a=commitdiff;h=$last_sha"
      )
      expect(subject.commit_url).to eq(
        "https://gerrit_server/gerrit/gitweb?p=repo.git;a=commitdiff;h=a7bc38b1010cf61019d78b65e09215ddc6fac42d"
      )
    end
  end

  context "#presentation_url" do
    it "should allow substituting $artifacts_directory" do
      subject = described_class.create!(
        :web_url          => "http://s.com/projects/xyz",
        :presentation_url => "$artifacts_directory/output/index.html",
        :last_sha         => "a7bc38b1010cf61019d78b65e09215ddc6fac42d"
      )
      expect(subject.presentation_url).to eq(
        "http://s.com/builds/xyz/a7bc38b1010cf61019d78b65e09215ddc6fac42d/artifacts/output/index.html"
      )
    end

    it "should allow substituting $web_url" do
      subject = described_class.create!(
        :web_url          => "http://s.com/projects/xyz",
        :presentation_url => "$web_url",
        :last_sha         => "a7bc38b1010cf61019d78b65e09215ddc6fac42d"
      )
      expect(subject.presentation_url).to eq("http://s.com/projects/xyz")
    end

    it "empty should default to the build_url" do
      subject = described_class.create!(
        :web_url          => "http://s.com/projects/xyz",
        :last_sha         => "a7bc38b1010cf61019d78b65e09215ddc6fac42d"
      )
      expect(subject.presentation_url).to eq("http://s.com/builds/xyz/a7bc38b1010cf61019d78b65e09215ddc6fac42d")
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
