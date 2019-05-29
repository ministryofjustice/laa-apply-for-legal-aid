require 'rails_helper'

RSpec.describe 'update client email address before application confirmation', type: :request do
  let(:application) { create(:legal_aid_application) }
  let(:application_id) { application.id }
  let(:provider) { application.provider }

  describe 'GET /providers/applications/:legal_aid_application_id/update_email_address' do
    subject { get "/providers/applications/#{application_id}/update_email_address" }

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
        expect(response.body).to include(I18n.translate('providers.applicants.show.email_label'))
        expect(unescaped_response_body).to include(I18n.translate('helpers.hint.applicant.email'))
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/update_email_address' do
    subject { patch "/providers/applications/#{application_id}/update_email_address", params: params }

    let(:application) { create :legal_aid_application }
    let(:provider) { application.provider }
    let(:params) do
      {
        applicant: {
          first_name: 'John',
          last_name: 'Doe',
          national_insurance_number: 'AA 12 34 56 C',
          dob_year: '1981',
          dob_month: '07',
          dob_day: '11',
          email: Faker::Internet.safe_email
        }
      }
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
      end

      context 'Continue button pressed' do
        let(:submit_button) { { continue_button: 'Continue' } }

        it 'redirects to next page' do
          subject
          expect(response.body).to redirect_to(providers_legal_aid_application_application_confirmation_path(application_id))
        end
      end
    end
  end
end
