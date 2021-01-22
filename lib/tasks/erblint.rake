desc 'Run ERB lint'
task erblint: :environment do
  path = 'app/views'
  sh("erblint #{path}")
end
