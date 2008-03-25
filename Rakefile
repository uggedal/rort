$: << File.expand_path("../lib", __FILE__)
%w(rubygems rake roert).each{|dep|require dep}

PORT = 8080
PID = "/tmp/thin.#{PORT}.pid"

task :default => :start

desc "Start the application"
task :start do
  `thin start -r run.ru -d -p #{PORT} -P #{PID}`
end

desc "Stop the application"
task :stop do
  `thin stop -P #{PID}`
end

desc "Migrate database schema"
task :migrate do
  DataMapper::Persistence.auto_migrate!
end
