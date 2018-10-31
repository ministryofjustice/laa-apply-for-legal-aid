if Gem.loaded_specs.key?('cucumber')
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new
end
