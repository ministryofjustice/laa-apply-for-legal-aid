require 'rails_helper'

RSpec.describe ProvidersHelper, type: :helper do
  let(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceeding_types_inc_section8 }
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
  let(:controllers_with_params) { %w[incoming_transactions outgoing_transactions remove_dependants] }
  let(:excluded_controllers) { %w[bank_transactions] + controllers_with_params }

  describe '#url_for_application' do
    subject { url_for_application(legal_aid_application) }
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

    context 'when saved as draft and amending involved child' do
      it do
        legal_aid_application.provider_step = 'involved_children'
        legal_aid_application.provider_step_params = { id: '21983d92-876d-4f95-84df-1af2e3308fd7' }
        expect(subject).to eq("/providers/applications/#{legal_aid_application.id}/involved_children/21983d92-876d-4f95-84df-1af2e3308fd7?locale=en")
      end
    end

    context 'when saved as draft and returning to a started involved child' do
      let(:partial_record) { create :involved_child, legal_aid_application: legal_aid_application, date_of_birth: nil }

      it do
        legal_aid_application.provider_step = 'involved_children'
        legal_aid_application.provider_step_params = { application_merits_task_involved_child: { full_name: partial_record.full_name }, id: 'new' }
        expect(subject).to eq("/providers/applications/#{legal_aid_application.id}/involved_children/#{partial_record.id}?locale=en")
      end
    end

    context 'when saved as draft and returning to a started involved child' do
      it do
        legal_aid_application.provider_step = 'involved_children'
        legal_aid_application.provider_step_params = { application_merits_task_involved_child: { full_name: nil }, id: 'new' }
        expect(subject).to eq("/providers/applications/#{legal_aid_application.id}/involved_children/new?locale=en")
      end
    end

    context 'when saved as draft and linking children' do
      it do
        legal_aid_application.provider_step = 'linked_children'
        legal_aid_application.provider_step_params = { merits_task_list_id: legal_aid_application.lead_application_proceeding_type.id }
        expect(subject).to eq("/providers/merits_task_list/#{legal_aid_application.lead_application_proceeding_type.id}/linked_children?locale=en")
      end
    end

    context 'when removing a dependant' do
      let(:dependant) { create :dependant, legal_aid_application: legal_aid_application }

      it 'routes correctly' do
        legal_aid_application.provider_step = 'remove_dependants'
        legal_aid_application.provider_step_params = { id: dependant.id }
        expect(url_for_application(legal_aid_application)).to eq("/providers/applications/#{legal_aid_application.id}/remove_dependants/#{dependant.id}?locale=en")
      end
    end
  end
end
