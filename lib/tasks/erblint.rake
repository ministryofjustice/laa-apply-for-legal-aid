desc 'Run ERB lint'
task :erblint do
  path = 'app/views'
  sh("erblint #{path}")
end
