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
  let(:controllers_with_params) { %w[incoming_transactions outgoing_transactions remove_dependant] }
  let(:excluded_controllers) { %w[bank_transactions] + controllers_with_params }

  describe '#url_for_application' do
    it 'should not crash' do
      (provider_controller_names - excluded_controllers).each do |controller_name|
        legal_aid_application.provider_step = controller_name
        url_for_application(legal_aid_application)
      end
    end

    it 'incoming_transactions should return the right URL with param' do
      legal_aid_application.provider_step = 'incoming_transactions'
      legal_aid_application.provider_step_params = { transaction_type: :salary }
      expect(url_for_application(legal_aid_application)).to eq("/providers/applications/#{legal_aid_application.id}/incoming_transactions/salary?locale=en")
    end

    it 'outgoing_transactions should return the right URL with param' do
      legal_aid_application.provider_step = 'outgoing_transactions'
      legal_aid_application.provider_step_params = { transaction_type: :salary }
      expect(url_for_application(legal_aid_application)).to eq("/providers/applications/#{legal_aid_application.id}/outgoing_transactions/salary?locale=en")
    end

    context 'when removing a dependant' do
      let(:dependant) { create :dependant, legal_aid_application: legal_aid_application }

      it 'routes correctly' do
        legal_aid_application.provider_step = 'remove_dependant'
        legal_aid_application.provider_step_params = { id: dependant.id }
        expect(url_for_application(legal_aid_application)).to eq("/providers/applications/#{legal_aid_application.id}/remove_dependant/#{dependant.id}?locale=en")
      end
    end
  end
end
