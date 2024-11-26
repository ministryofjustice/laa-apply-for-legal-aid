# Use to have specs handle errors as they would be on production
#
RSpec.configure do |config|
  config.before(:each, :show_exceptions) do
    method = Rails.application.method(:env_config)

    allow(Rails.application).to receive(:env_config).with(no_args) do
      method.call.merge(
        "action_dispatch.show_exceptions" => true,
        "action_dispatch.show_detailed_exceptions" => false,
        "consider_all_requests_local" => true,
      )
    end
  end
end
