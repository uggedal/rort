NAME = File.basename(Dir.pwd)

task :default => :start

desc "Start #{NAME}"
task :start do
  `god -c config.god`
end

desc "Stop #{NAME}"
task :stop do
  `god terminate`
end

desc "Restart #{NAME}"
task :restart => [:stop, :start]

desc "Install dependencies"
task :install do
  gems = %w(rack
            mongrel
            memcache-client
            json
            rspec
            god
            sqlite3-ruby
            sequel
            ParseTree)
  `gem install #{gems.join(' ')}`
  `gem install ext/hpricot-0.6_bufoverflowfix.gem`
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/*_spec.rb']
  t.spec_files << FileList['spec/**/*_spec.rb']
  t.spec_files << FileList['spec/**/**/*_spec.rb']
  t.spec_opts = ['-c']
end 

desc 'Show code/spec status'
task :status do
  code = FileList['lib/*.rb']
  code << FileList['lib/**/*.rb']
  code << FileList['lib/**/**/*.rb']
  code.flatten!

  specs = FileList['spec/*_spec.rb']
  specs << FileList['spec/**/*_spec.rb']
  specs << FileList['spec/**/**/*_spec.rb']
  specs.flatten!

  code_lines = code.inject(0) do |sum, f|
    sum + File.open(f).readlines.size
  end

  spec_lines = specs.inject(0) do |sum, f|
    sum + File.open(f).readlines.size
  end

  puts "Code/Spec: #{specs.size}/#{code.size} specs/files | "+
       "#{spec_lines}/#{code_lines} los/loc | " +
       "#{spec_lines * 100 / code_lines} %"
end

namespace :cache do

  $: << File.expand_path("../lib", __FILE__)
  require 'rort'

  desc 'Show the size of the cache'
  task :size do
    size = Rort::Cache.size
    case size
    when 0..1024
      puts "#{size}B"
    when 1024..1024*1024
      puts "#{size/1024}kB"
    else
      puts "#{size/(1024*1024)}MB"
    end
  end
end
