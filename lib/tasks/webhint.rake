namespace :webhint do
  desc 'Run webhint and output reports'
  task :generate_reports do
    sh 'rm -rf hint-report/*'
    sh 'rm -rf tmp/webhint_inputs/*'
    sh 'SAVE_PAGES=true ./bin/rails cucumber'
    sh './bin/generate_webhint_reports.sh'
  end
end
