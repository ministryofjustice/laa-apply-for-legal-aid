require 'rails_helper'

RSpec.describe 'check your answers requests', type: :request do
  include ActionView::Helpers::NumberHelper
  let!(:legal_aid_application) { create :legal_aid_application, :provider_submitted, :with_everything }
  let!(:restriction) { create :restriction, legal_aid_applications: [legal_aid_application] }
  let(:secure_id) { legal_aid_application.generate_secure_id }
  before do
    get citizens_legal_aid_application_path(secure_id)
  end

  describe 'GET /citizens/check_answers' do
    subject { get '/citizens/check_answers' }
    before { subject }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the correct details' do
      expect(response.body).to include(I18n.translate("shared.forms.own_home_form.#{legal_aid_application.own_home}"))
      expect(response.body).to include(number_to_currency(legal_aid_application.property_value, unit: '£'))
      expect(response.body).to include(number_to_currency(legal_aid_application.outstanding_mortgage_amount, unit: '£'))
      expect(response.body).to include(I18n.translate("shared.forms.shared_ownership_form.shared_ownership_item.#{legal_aid_application.shared_ownership}"))
      expect(response.body).to include(number_to_percentage(legal_aid_application.percentage_home, precision: 2))
      expect(response.body).to include('Own the home')
      expect(response.body).to include('Property value')
      expect(response.body).to include('Outstanding mortgage')
      expect(response.body).to include('Owned with anyone else')
      expect(response.body).to include('Percentage')
      expect(response.body).to include('Savings')
      expect(response.body).to include('assets')
      expect(response.body).to include('restrictions')
    end

    it 'displays the correct URLs for changing values' do
      expect(response.body).to have_change_link(:own_home, citizens_own_home_path)
      expect(response.body).to have_change_link(:property_value, citizens_property_value_path(anchor: 'property_value'))
      expect(response.body).to have_change_link(:shared_ownership, citizens_shared_ownership_path)
      expect(response.body).to have_change_link(:percentage_home, citizens_percentage_home_path(anchor: 'percentage_home'))
      expect(response.body).to include(citizens_savings_and_investment_path)
      expect(response.body).to include(citizens_other_assets_path)
      expect(response.body).to include(citizens_restrictions_path)
    end

    it 'displays the correct savings details' do
      legal_aid_application.savings_amount.amount_attributes.each do |_, amount|
        expect(response.body).to include(number_to_currency(amount, unit: '£')), 'saving amount should be in the page'
      end
    end

    it 'displays the correct assets details' do
      legal_aid_application.other_assets_declaration.amount_attributes.each do |_, amount|
        expect(response.body).to include(number_to_currency(amount, unit: '£')), 'asset amount should be in the page'
      end
    end

    it 'should change the state to "checking_citizen_answers"' do
      expect(legal_aid_application.reload.checking_citizen_answers?).to be_truthy
    end

    context 'applicant does not own home' do
      let(:legal_aid_application) { create :legal_aid_application, :with_everything, :without_own_home }
      it 'does not display property value' do
        expect(response.body).not_to include(number_to_currency(legal_aid_application.property_value, unit: '£'))
        expect(response.body).not_to include('Property value')
      end

      it 'does not display shared ownership question' do
        expect(response.body).not_to include(I18n.translate("shared.forms.shared_ownership_form.shared_ownership_item.#{legal_aid_application.shared_ownership}"))
        expect(response.body).not_to include('Owned with anyone else')
      end
    end

    context 'applicant owns home without mortgage' do
      let(:legal_aid_application) { create :legal_aid_application, :with_everything, :with_own_home_owned_outright }
      it 'does not display property value' do
        expect(response.body).not_to include(number_to_currency(legal_aid_application.outstanding_mortgage_amount, unit: '£'))
        expect(response.body).not_to include('Outstanding mortgage')
      end
    end

    context 'applicant is sole owner of home' do
      let(:legal_aid_application) { create :legal_aid_application, :with_everything, :with_home_sole_owner }
      it 'does not display percentage owned' do
        expect(response.body).not_to include(number_to_percentage(legal_aid_application.percentage_home, precision: 2))
        expect(response.body).not_to include('Percentage')
      end
    end

    context 'applicant does not have any capital' do
      let(:legal_aid_application) { create :legal_aid_application, :provider_submitted, :with_applicant, :without_own_home }
      it 'does not display capital restrictions' do
        expect(response.body).not_to include('restrictions')
      end
    end
  end

  describe 'PATCH /citizens/check_answers/continue' do
    subject { patch '/citizens/check_answers/continue' }

    before do
      legal_aid_application.check_citizen_answers!
    end

    it 'should redirect to next step' do
      subject
      expect(response.body).to eq('citizens_application_submitted_path')
    end

    xit 'should redirect to next step' do
      # TODO: implement when next step is known
      # expect(response).to redirect_to(...)
    end

    it 'should change the state to means_completed' do
      subject
      expect(legal_aid_application.reload.means_completed?).to be_truthy
    end

    it 'syncs the application' do
      expect(CleanupCapitalAttributes).to receive(:call).with(legal_aid_application)
      subject
    end
  end

  describe 'PATCH /citizens/check_answers/reset' do
    subject { patch '/citizens/check_answers/reset' }

    before do
      legal_aid_application.check_citizen_answers!
      get citizens_restrictions_path
      get citizens_check_answers_path
      subject
    end

    it 'should redirect back' do
      expect(response).to redirect_to(citizens_restrictions_path(back: true))
    end

    it 'should change the state back to "provider_submitted"' do
      expect(legal_aid_application.reload.provider_submitted?).to be_truthy
    end
  end
end
