NAME = File.basename(Dir.pwd)
SOCK = "/tmp/thin.#{NAME}.sock"
PID = "/tmp/thin.#{NAME}.pid"

task :default => :start

desc "Start #{NAME}"
task :start do
  `thin start -R run.ru -d -S #{SOCK} -P #{PID}`
end

desc "Stop #{NAME}"
task :stop do
  `thin stop -P #{PID}`
end

desc "Restart #{NAME}"
task :restart => [:stop, :start]
