NAME = File.basename(Dir.pwd)

task :default => :start

desc "Start #{NAME}"
task :start do
  `god -c rort.god`
end

desc "Stop #{NAME}"
task :stop do
  `god terminate`
end

desc "Restart #{NAME}"
task :restart => [:stop, :start]

desc "Install dependencies"
task :install do
  `gem install rack mongrel memcache-client json daemons rspec god`
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
  code = FileList['lib/**/*.rb']
  specs = FileList['spec/**/*_spec.rb']

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
