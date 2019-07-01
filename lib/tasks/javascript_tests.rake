desc 'Run JavaScript unit tests'
task :javascript_tests do
  sh('yarn test')
end
