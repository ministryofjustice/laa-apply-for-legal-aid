desc "Run ERB lint"
task erblint: :environment do
  path = "app/views app/components"
  sh("erb_lint #{path}")
end
