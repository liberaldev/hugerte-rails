require File.expand_path('../lib/hugerte/rails/version', __FILE__)

def step(name)
  print "#{name} ..."
  yield
  puts " DONE"
end

def download(url, filename)
  puts "Downloading #{url} ..."
  `mkdir -p tmp`
  `curl -L -# #{url} -o tmp/#{filename}`
end

desc "Update HugeRTE to version #{HugeRTE::Rails::HUGERTE_VERSION}"
task :update => [ :fetch, :extract ]

task :fetch do
  download("https://github.com/hugerte/hugerte-dist/archive/refs/tags/v#{HugeRTE::Rails::HUGERTE_VERSION}.zip", "hugerte.zip")
end

task :extract do
  step "Extracting core files" do
    `rm -rf tmp/hugerte-dist-*`
    `unzip -u tmp/hugerte.zip -d tmp`
    `rm -rf vendor/assets/javascripts/hugerte`
    `mkdir -p vendor/assets/javascripts/hugerte`
    `cp -r tmp/hugerte-dist-#{HugeRTE::Rails::HUGERTE_VERSION}/* vendor/assets/javascripts/hugerte/`
  end

  step "Extracting unminified source" do
   `mkdir -p app/assets/source/hugerte`
   `mv tmp/hugerte-dist-#{HugeRTE::Rails::HUGERTE_VERSION}/hugerte.js app/assets/source/hugerte/hugerte.js`
   `rm -rf tmp/hugerte-dist-#{HugeRTE::Rails::HUGERTE_VERSION}`
  end
end

=begin
task :rename do
  step "Renaming files" do
    Dir["vendor/assets/javascripts/hugerte/**/*.min.js"].each do |file|
      FileUtils.mv(file, file.sub(/\.min\.js$/, '.js'))
    end

    Dir["vendor/assets/javascripts/hugerte/**/*.min.css"].each do |file|
      FileUtils.cp(file, file.sub(/\.min\.css$/, '.css'))
    end
  end
end
=end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

require "bundler/gem_tasks"
