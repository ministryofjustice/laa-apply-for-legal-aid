desc "Run ERB lint"
task erblint: :environment do
  path = "app/views app/components"
  sh("erblint #{path}")
end
