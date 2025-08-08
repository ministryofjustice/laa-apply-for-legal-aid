require "super_diff/rspec-rails"
require_relative "../../spec/services/pda/provider_details_request_stubs"

# before, after and around hooks for feature tests
#
Before("@hmrc_use_dev_mock") do
  allow(Rails.configuration.x).to receive(:hmrc_use_dev_mock).and_return(true)
end

After("@hmrc_use_dev_mock") do
  allow(Rails.configuration.x).to receive(:hmrc_use_dev_mock).and_call_original
end

Before("not @clamav") do
  stdout = "/some/file/path.pdf: OK"
  stderr = ""
  status = instance_double(Process::Status, success?: true, exitstatus: 0)
  allow(Open3).to receive(:capture3).and_call_original
  allow(Open3)
    .to receive(:capture3)
    .with(/clamdscan/, any_args)
    .and_return([stdout, stderr, status])
end

Around("@disable-rack-attack") do |_scenario, block|
  Rack::Attack.reset!
  Rack::Attack.enabled = false
  block.call
  Rack::Attack.enabled = true
end

Before("@stub_pda_provider_details") do
  allow(PDA::ProviderDetails).to receive(:call).and_return(true) # this stubs out calls to the pda schedules endpoint
end

Around("@stub_office_schedules_and_user") do |_scenario, block|
  stub_office_schedules_for_0x395u
  stub_provider_user_for_test_provider
  stub_office_schedules_not_found_for("2N078D")
  stub_office_schedules_not_found_for("A123456")

  # turn off vcr to allow stubs to function
  VCR.turned_off { block.call }
end
