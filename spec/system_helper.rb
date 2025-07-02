# Idea from https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing
#

# Load general RSpec Rails configuration
require "rails_helper"

# Load configuration files and helpers
Dir[File.join(__dir__, "system/support/**/*.rb")].each do |file|
  next if file.match?("spec_helper.rb")

  require file
end

require File.join(__dir__, "system/support/spec_helper.rb")
