require 'rails_helper'
RSpec.describe 'provider percentage share of home test', type: :request do
  let!(:application) { create :legal_aid_application, :with_applicant }
  let(:provider) { application.provider }

  describe 'GET #/providers/applications/:legal_aid_application_id/percentage_home' do
    subject { get providers_legal_aid_application_percentage_home_path(application) }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'PATCH #/providers/applications/:legal_aid_application_id/percentage_home' do
    let(:percentage_home) { '33.33' }
    let(:params) do
      {
        legal_aid_application: { percentage_home: percentage_home }
      }
    end

    subject { patch providers_legal_aid_application_percentage_home_path(application), params: params.merge(submit_button) }

    context 'when the provider is authenticated' do
      before do
        login_as provider
      end

      context 'Submitted with Continue button' do
        let(:submit_button) do
          {
            continue_button: 'Continue'
          }
        end

        it 'updates the legal_aid_application' do
          expect { subject }.to change { application.reload.percentage_home.to_s }.to(percentage_home)
        end

        it 'does not displays an error' do
          subject
          expect(response.body).not_to match('govuk-error-message')
          expect(response.body).not_to match('govuk-form-group--error')
        end

        it 'redirects to the next step in Provider jouney' do
          subject
          expect(response).to redirect_to flow_forward_path
        end
        context 'with invalid input' do
          let(:percentage_home) { 'fifty' }

          it 'renders successfully' do
            subject
            expect(response).to have_http_status(:ok)
          end

          it 'displays an error' do
            subject
            expect(response.body).to match(I18n.t('activemodel.errors.models.legal_aid_application.attributes.percentage_home.not_a_number'))
            expect(response.body).to match('govuk-error-message')
            expect(response.body).to match('govuk-form-group--error')
          end
        end
      end

      context 'Submitted with Save as draft button' do
        let(:submit_button) do
          {
            draft_button: 'Save as draft'
          }
        end

        it 'updates the legal_aid_application' do
          expect { subject }.to change { application.reload.percentage_home.to_s }.to(percentage_home)
        end

        it 'does not displays an error' do
          subject
          expect(response.body).not_to match('govuk-error-message')
          expect(response.body).not_to match('govuk-form-group--error')
        end

        it 'redirects to the Provider home page' do
          subject
          expect(response).to redirect_to providers_legal_aid_applications_path
        end
        context 'with invalid input' do
          let(:percentage_home) { 'fifty' }

          it 'renders successfully' do
            subject
            expect(response).to have_http_status(:ok)
          end

          it 'displays an error' do
            subject
            expect(response.body).to match(I18n.t('activemodel.errors.models.legal_aid_application.attributes.percentage_home.not_a_number'))
            expect(response.body).to match('govuk-error-message')
            expect(response.body).to match('govuk-form-group--error')
          end
        end
      end
    end
  end
end
