require "super_diff/rspec-rails"
require Rails.root.join("spec/services/pda/provider_details_request_stubs")
require Rails.root.join("spec/support/bank_holiday_retriever_stubs")

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
  double = instance_double(PDA::ProviderDetailsUpdater, call: nil, has_valid_schedules?: true)
  allow(PDA::ProviderDetailsUpdater).to receive(:new).and_return(double)
end

After("@stub_pda_provider_details") do
  # unstub
  allow(PDA::ProviderDetailsUpdater).to receive(:new).and_call_original
end

Around("@stub_office_schedules_and_user") do |_scenario, block|
  stub_office_schedules_for_0x395u
  stub_provider_user_for("51cdbbb4-75d2-48d0-aaac-fa67f013c50a")
  stub_office_schedules_not_found_for("2N078D")
  stub_office_schedules_not_found_for("A123456")

  VCR.turned_off { block.call }
ensure
  # Unstub
  WebMock.reset!
end

Around("@stub_bank_holidays") do |_scenario, block|
  stub_bankholiday_success

  VCR.turned_off { block.call }
ensure
  # Unstub
  WebMock.reset!
end

Around("@stub_office_schedules_but_ccms_user_not_found") do |_scenario, block|
  stub_office_schedules_for_0x395u
  stub_office_schedules_not_found_for("2N078D")
  stub_office_schedules_not_found_for("A123456")
  stub_provider_user_failure_for("51cdbbb4-75d2-48d0-aaac-fa67f013c50a", status: 404, body: nil)

  VCR.turned_off { block.call }
ensure
  # Unstub
  WebMock.reset!
end

Before("@mock_auth_enabled") do |_scenario, _block|
  allow(Rails.configuration.x.omniauth_entraid).to receive(:mock_auth_enabled).and_return(true)
  Rails.application.reload_routes!
end

After("@mock_auth_enabled") do |_scenario, _block|
  allow(Rails.configuration.x.omniauth_entraid).to receive(:mock_auth_enabled).and_call_original
  Rails.application.reload_routes!
end

Before("@mock_admin_auth_enabled") do |_scenario, _block|
  allow(Rails.configuration.x.admin_omniauth).to receive(:mock_auth_enabled).and_return(true)
  Rails.application.reload_routes!
end

After("@mock_admin_auth_enabled") do |_scenario, _block|
  allow(Rails.configuration.x.admin_omniauth).to receive(:mock_auth_enabled).and_call_original
  Rails.application.reload_routes!
end

Around("@vcr_turned_off") do |_scenario, block|
  VCR.turned_off { block.call }
end

Before("@mock_auth_enabled_on_production") do |_scenario, _block|
  # turn on entra id auth mocking.
  OmniAuth.config.test_mode = true
  OmniAuth::Strategies::Silas.mock_auth

  allow(Rails.configuration.x.omniauth_entraid).to receive(:mock_auth_enabled).and_return(true)
  allow(HostEnv).to receive(:environment).and_return(:production)
  Rails.application.reload_routes!
end

After("@mock_auth_enabled_on_production") do |_scenario, _block|
  # unmock entraid auth
  OmniAuth.config.mock_auth[:entra_id] = nil
  OmniAuth.config.test_mode = true

  allow(Rails.configuration.x.omniauth_entraid).to receive(:mock_auth_enabled).and_call_original
  allow(HostEnv).to receive(:environment).and_call_original

  Rails.application.reload_routes!
end
