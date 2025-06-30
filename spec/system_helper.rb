# Idea from https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing
#

# Load general RSpec Rails configuration
require "rails_helper"

# Load configuration files and helpers
Dir[File.join(__dir__, "system/support/**/*.rb")].each { |file| require file }
