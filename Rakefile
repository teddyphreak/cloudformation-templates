require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'cfndsl/rake_task'

def templates
  Dir["./templates/*.rb"].collect { |t| 
    {
      filename: t,
      output: "#{File.basename(t, '.rb')}.json"
    }
  }
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end

CfnDsl::RakeTask.new(:generate) do |template|
  template.cfndsl_opts = {
    verbose: true,
    pretty: true,
    files: templates
  }
end

task :default => [:generate, :features]
