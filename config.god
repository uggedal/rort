#!/usr/bin/env ruby
# -*- ruby -*-

require 'rubygems'
require 'god'

God.pid_file_directory = File.expand_path("../run", __FILE__)

bg = File.expand_path("../lib/rort/background.rb", __FILE__)
http = File.expand_path("../lib/rort/rack.rb", __FILE__)

God::Contacts::Email.message_settings = {
  :from => 'rort.god@redflavor.com'
}

God::Contacts::Email.server_settings = {
  :address => "smtp.online.no",
  :port => 25
}

God.contact(:email) do |c|
  c.name = 'eivindu'
  c.email = 'eu@redflavor.com'
end

def should_be_running(process)
  process.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end
end

def restart_on_mem_and_cpu(process)
  process.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 100.megabytes
      c.times = [3, 5]
      c.notify = 'eivindu'
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 80.percent
      c.times = [3, 5]
      c.notify = 'eivindu'
    end
  end
end

[*1..5].each do |number|
  God.watch do |w|

    w.name = "rortbg_#{number}"
    w.group = 'rortbg'

    w.start = "ruby #{bg}"

    w.interval = 30.seconds
    w.grace = 10.seconds

    w.behavior(:clean_pid_file)

    should_be_running(w)
    restart_on_mem_and_cpu(w)
  end
end

God.watch do |w|

  w.name = 'rorthttp'

  w.start = "ruby #{http}"

  w.interval = 30.seconds
  w.grace = 10.seconds

  w.behavior(:clean_pid_file)

  should_be_running(w)
  restart_on_mem_and_cpu(w)
end
