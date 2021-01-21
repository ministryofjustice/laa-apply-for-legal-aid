require 'rails_helper'

RSpec.describe 'update client email address before application confirmation', type: :request do
  let(:application) { create(:legal_aid_application) }
  let(:application_id) { application.id }
  let(:provider) { application.provider }

  describe 'GET /providers/applications/:legal_aid_application_id/email_address' do
    subject { get "/providers/applications/#{application_id}/email_address" }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
      end

      it 'returns http success' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'displays the email label' do
        subject
        expect(response.body).to include(I18n.t('shared.forms.applicant_form.email_label'))
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/email_address' do
    subject { patch "/providers/applications/#{application_id}/email_address", params: params }

    let(:application) { create :legal_aid_application }
    let(:provider) { application.provider }
    let(:params) do
      {
        applicant: {
          email: Faker::Internet.safe_email
        }
      }
    end

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
      end

      context 'Continue button pressed' do
        let(:submit_button) { { continue_button: 'Continue' } }

        it 'redirects to next page' do
          subject
          expect(response.body).to redirect_to(providers_legal_aid_application_about_the_financial_assessment_path(application_id))
        end
      end
    end
  end
end
