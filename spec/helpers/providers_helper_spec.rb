require 'rails_helper'

RSpec.describe ProvidersHelper, type: :helper do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:provider_routes) do
    Rails.application.routes.routes.select do |route|
      route.defaults[:controller].to_s.split('/')[0] == 'providers' &&
        route.parts.include?(:legal_aid_application_id)
    end
  end
  let(:provider_controller_names) do
    provider_routes.map { |route|
      route.defaults[:controller].to_s.split('/')[1]
    }.uniq
  end
  let(:excluded_controllers) { %w[bank_transactions] }

  describe '#url_for_application' do
    it 'should not crash' do
      (provider_controller_names - excluded_controllers).each do |controller_name|
        legal_aid_application.provider_step = controller_name
        url_for_application(legal_aid_application)
      end
    end
  end
end
