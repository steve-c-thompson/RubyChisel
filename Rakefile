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

desc "Create output file from my_input.markdown"
task :input_to_output do
  require 'date'
  d_string = DateTime.now.to_s
  ruby "lib/markdown_file_parser.rb ./my_input.markdown output#{d_string}.html"
end

task default: ["test", "spec"]
