#!/usr/bin/env ruby
# -*- ruby -*-

require 'rubygems'
require 'god'

God.pid_file_directory = File.expand_path('../', __FILE__)

bg = File.expand_path("../lib/rort/background.rb", __FILE__)
http = File.expand_path("../lib/rort/rack.rb", __FILE__)

[*1..5].each do |number|
  God.watch do |w|

    w.name = "rortbg_#{number}"
    w.group = 'rortbg'

    w.start = "ruby #{bg}"

    w.interval = 60.seconds
    w.grace = 10.seconds

    w.behavior(:clean_pid_file)

    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = 5.seconds
        c.running = false
      end
    end
  end
end

God.watch do |w|

  w.name = 'rorthttp'

  w.start = "ruby #{http}"

  w.interval = 60.seconds
  w.grace = 10.seconds

  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
end
