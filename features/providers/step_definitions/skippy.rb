# Allows scenarios to be skipped
# See: https://relishapp.com/cucumber/cucumber/docs/defining-steps/skip-scenario
Given(/skip.*this scenario/) do
  skip_this_scenario
end
