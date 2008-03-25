APPLICATION = "#{File.dirname(__FILE__)}"
BASEDIR = File.expand_path(File.dirname(__FILE__))

%w(rubygems rake).each{|dep|require dep}

PORT = 8080
PID = "/tmp/thin.#{PORT}.pid"

#task :default => Rake::Task['start']

desc "Start the application"
task :start do
  `thin start -r run.ru -d -p #{PORT} -P #{PID}`
end

desc "Stop the application"
task :stop do
  `thin stop -P #{PID}`
end
