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
task :update => [ :fetch, :extract, :rename ]

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

task :rename do
  step "Renaming files" do
    Dir["vendor/assets/javascripts/hugerte/**/*.min.js"].each do |min_file|
      js_file = min_file.sub(/\.min\.js$/, '.js')
      if File.exist?(js_file)
        FileUtils.rm(js_file)
        FileUtils.mv(min_file, js_file)
        puts "Replaced #{js_file} with #{min_file}"
      end
    end

    Dir["vendor/assets/javascripts/hugerte/**/*.min.css"].each do |min_file|
      css_file = min_file.sub(/\.min\.css$/, '.css')
      if File.exist?(css_file)
        FileUtils.rm(css_file)
        FileUtils.cp(min_file, css_file)
        puts "Replaced #{css_file} with #{min_file}"
      end
    end
  end
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

require "bundler/gem_tasks"
