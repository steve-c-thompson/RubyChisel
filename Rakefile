require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end


begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  # task :default => :spec
  rescue LoadError
    # no rspec available
end

task default: ["test", "spec"]
