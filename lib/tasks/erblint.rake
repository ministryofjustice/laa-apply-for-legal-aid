desc "Run ERB lint"
task erblint: :environment do
  path = "app/views"
  sh("erb_lint #{path}")
end
