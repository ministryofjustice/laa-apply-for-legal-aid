require 'rails_helper'

RSpec.describe 'client received legal help', type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:provider) { legal_aid_application.provider }

  describe 'GET providers/client_received_legal_help' do
    subject { get providers_legal_aid_application_client_received_legal_help_path(legal_aid_application) }

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

  describe 'PATCH providers/client_received_legal_help' do
    subject { patch providers_legal_aid_application_client_received_legal_help_path(legal_aid_application), params: params.merge(submit_button) }
    let(:client_received_legal_help) { false }
    let(:application_purpose) { Faker::Lorem.paragraph }
    let(:params) do
      {
        merits_assessment: {
          client_received_legal_help: client_received_legal_help.to_s,
          application_purpose: application_purpose
        }
      }
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      context 'Continue button pressed' do
        let(:submit_button) do
          {
            continue_button: 'Continue'
          }
        end

        it 'updates the record' do
          expect(legal_aid_application.merits_assessment.reload.client_received_legal_help).to eq(client_received_legal_help)
          expect(legal_aid_application.merits_assessment.reload.application_purpose).to eq(application_purpose)
        end

        it 'redirects to the next page' do
          expect(response).to redirect_to providers_legal_aid_application_proceedings_before_the_court_path(legal_aid_application)
        end
      end

      context 'Save as draft button pressed' do
        let(:submit_button) do
          {
            draft_button: 'Save as draft'
          }
        end

        it 'updates the record' do
          expect(legal_aid_application.merits_assessment.reload.client_received_legal_help).to eq(client_received_legal_help)
          expect(legal_aid_application.merits_assessment.reload.application_purpose).to eq(application_purpose)
        end

        it 'redirects to provider applications home page' do
          expect(response).to redirect_to providers_legal_aid_applications_path
        end

        it 'sets application as draft' do
          expect(legal_aid_application.reload).to be_draft
        end

        context 'nothing specified' do
          let(:client_received_legal_help) { nil }
          let(:application_purpose) { nil }

          it 'redirects to provider applications home page' do
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end

        context 'application_purpose missing' do
          let(:client_received_legal_help) { true }
          let(:application_purpose) { nil }

          it 'redirects to provider applications home page' do
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end

        context 'application_purpose missing' do
          let(:client_received_legal_help) { false }
          let(:application_purpose) { nil }

          it 'renders an error' do
            expect(response).to have_http_status(:ok)
            expect(response.body).to include('data-module="govuk-error-summary"')
          end
        end
      end
    end
  end
end
