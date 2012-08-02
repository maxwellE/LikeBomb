require 'rake/testtask'

Rake::TestTask.new do |i|
  i.test_files = FileList['test/*.rb']
  i.verbose = true
end

desc "Run tests"
task :default => :test
