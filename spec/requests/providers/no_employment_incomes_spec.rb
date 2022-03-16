require 'rails_helper'

RSpec.describe Providers::NoEmploymentIncomesController, type: :request do
  let(:application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine }
  let(:provider) { application.provider }

  before { create :hmrc_response, :use_case_one, legal_aid_application_id: application.id }

  describe 'GET /providers/applications/:id/no_employment_income' do
    subject { get providers_legal_aid_application_no_employment_income_path(application) }

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

  describe 'PATCH /providers/applications/:id/no_employment_income' do
    subject { patch providers_legal_aid_application_no_employment_income_path(application), params: params.merge(submit_button) }
    let(:full_employment_details) { Faker::Lorem.paragraph }
    let(:params) do
      {
        legal_aid_application: {
          full_employment_details: full_employment_details
        }
      }
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      context 'Form submitted with continue button' do
        let(:submit_button) do
          {
            continue_button: 'Continue'
          }
        end

        it 'updates legal aid application employment details' do
          expect(application.reload.full_employment_details).to eq full_employment_details
        end

        it 'redirects to income summary page' do
          expect(response).to redirect_to(providers_legal_aid_application_no_income_summary_path(application))
        end

        context 'invalid params' do
          let(:full_employment_details) { '' }

          it 'displays error' do
            expect(unescaped_response_body).to include(I18n.t('activemodel.errors.models.legal_aid_application.attributes.full_employment_details.blank'))
          end
        end
      end

      context 'Form submitted with Save as draft button' do
        let(:submit_button) do
          {
            draft_button: 'Save as draft'
          }
        end

        context 'after success' do
          before do
            login_as provider
            subject
            application.reload
          end

          it 'updates the legal_aid_application.extra_employment_information' do
            expect(application.full_employment_details).to eq full_employment_details
          end

          it 'redirects to the list of applications' do
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end
      end
    end
  end
end
