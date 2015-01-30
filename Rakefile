task :default => :busted

desc "Run lua tests"
task :busted do
  system('busted')
end

desc "Create minified build"
task :minify do
  system('squish')
end

task :doc do
  system('ldoc enumerable.lua')
end
