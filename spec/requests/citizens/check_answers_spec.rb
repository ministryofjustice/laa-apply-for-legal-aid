require 'rails_helper'

RSpec.describe 'check your answers requests', type: :request do
  include ActionView::Helpers::NumberHelper
  let(:legal_aid_application) { create :legal_aid_application, :provider_submitted, :with_everything }
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
      expect(unescaped_response_body).to include(I18n.translate("shared.forms.own_home_form.#{legal_aid_application.own_home}"))
      expect(unescaped_response_body).to include(number_to_currency(legal_aid_application.property_value, unit: '£'))
      expect(unescaped_response_body).to include(number_to_currency(legal_aid_application.outstanding_mortgage_amount, unit: '£'))
      expect(unescaped_response_body).to include(I18n.translate("shared.forms.shared_ownership_form.shared_ownership_item.#{legal_aid_application.shared_ownership}"))
    end

    it 'displays the correct savings details' do
      legal_aid_application.savings_amount.amount_attributes.each do |_, amount|
        expect(unescaped_response_body).to include(number_to_currency(amount, unit: '£')), 'saving amount should be in the page'
      end
    end

    it 'displays the correct assets details' do
      legal_aid_application.other_assets_declaration.amount_attributes.each do |_, amount|
        expect(unescaped_response_body).to include(number_to_currency(amount, unit: '£')), 'asset amount should be in the page'
      end
    end
  end

  describe 'POST /citizens/check_answers/continue' do
    subject { post '/citizens/check_answers/continue' }
    before { subject }

    it 'should redirect to next step' do
      expect(response.body).to eq('citizens_application_submitted_path')
    end

    xit 'should redirect to next step' do
      # TODO: implement when next step is known
      # expect(response).to redirect_to(...)
    end

    it 'should change the state to means_completed' do
      expect(legal_aid_application.reload.means_completed?).to be_truthy
    end
  end
end
