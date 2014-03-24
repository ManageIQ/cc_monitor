class CreateServers < ActiveRecord::Migration
  def up
    create_table :servers do |t|
      t.string :url

      t.timestamps
    end

    say_with_time("Importing servers from file") do
      file = Rails.root.join("config", "project_urls.yml")
      if File.file?(file)
        YAML.load_file(file).each { |url| Server.create(:url => url) }
        FileUtils.rm(file)
      end
    end
  end

  def down
    say_with_time("Exporting servers to file") do
      yaml = YAML.dump(Server.all.collect(&:url))
      file = Rails.root.join("config", "project_urls.yml")
      File.write(file, yaml)
    end

    drop_table :servers
  end
end
