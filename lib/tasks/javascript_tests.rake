desc 'Run JavaScript unit tests'
task javascript_tests: :environment do
  sh('yarn test')
end
