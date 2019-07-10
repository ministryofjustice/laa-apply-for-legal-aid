require 'rails_helper'

RSpec.describe 'citizen restrictions request', type: :request do
  let(:application) { create :legal_aid_application, :with_applicant }
  let(:secure_id) { application.generate_secure_id }

  before do
    get citizens_legal_aid_application_path(secure_id)
  end

  describe 'GET /citizens/restrictions' do
    before { get citizens_restrictions_path }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /citizens/restrictions' do
    let(:params) do
      {
        legal_aid_application: {
          has_restrictions: has_restrictions,
          restrictions_details: restrictions_details
        }
      }
    end
    let(:restrictions_details) { Faker::Lorem.paragraph }
    let(:has_restrictions) { true }
    let(:submit_button) do
      {
        continue_button: 'Continue'
      }
    end

    subject { patch citizens_restrictions_path, params: params.merge(submit_button) }

    before { subject }

    it 'updates legal aid application restriction information' do
      expect(application.reload.has_restrictions).to eq true
      expect(application.reload.restrictions_details).to_not be_empty
    end

    it 'redirects to citizens check answers' do
      expect(response).to redirect_to(citizens_check_answers_path)
    end

    context 'invalid params' do
      let(:restrictions_details) { '' }

      it 'displays error' do
        expect(response.body).to include(translation_for(:restrictions_details, 'blank'))
      end

      context 'no params' do
        let(:has_restrictions) { nil }

        it 'displays error' do
          expect(response.body).to include(translation_for(:has_restrictions, 'blank'))
        end
      end
    end

    context 'checking answers' do
      let(:application) { create :legal_aid_application, :with_applicant, state: :checking_citizen_answers }

      it 'redirects to checking answers' do
        expect(response).to redirect_to(citizens_check_answers_path)
      end
    end
  end

  def translation_for(attr, error)
    I18n.t("activemodel.errors.models.legal_aid_application.attributes.#{attr}.citizen.#{error}")
  end
end
