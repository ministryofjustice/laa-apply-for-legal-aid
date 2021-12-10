require 'rails_helper'

RSpec.describe 'employed incomes request', type: :request do
  let(:application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine }
  let(:provider) { application.provider }
  before { create :hmrc_response, :use_case_one, legal_aid_application_id: application.id }

  describe 'GET /providers/applications/:id/employed_income' do
    subject { get providers_legal_aid_application_employment_income_path(application) }

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

  describe 'PATCH /providers/applications/:id/employed_income' do
    subject { patch providers_legal_aid_application_employment_income_path(application), params: params.merge(submit_button) }
    let(:params) do
      {
        legal_aid_application: {
          extra_employment_information: extra_employment_information,
          employment_information_details: employment_information_details
        }
      }
    end
    let(:employment_information_details) { Faker::Lorem.paragraph }
    let(:extra_employment_information) { 'true' }

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

        it 'updates legal aid application restriction information' do
          expect(application.reload.extra_employment_information).to eq true
          expect(application.reload.employment_information_details).to_not be_empty
        end

        context 'when the provider has confirmed the information' do
          it 'redirects to income summary page' do
            expect(response).to redirect_to(providers_legal_aid_application_no_income_summary_path(application))
          end
        end

        context 'when the applicant has reported income' do
          let!(:salary) { create :transaction_type, :credit, name: 'salary' }
          let!(:benefits) { create :transaction_type, :credit, name: 'benefits' }
          let(:application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, transaction_types: [salary, benefits] }

          it 'redirects to check passported answers' do
            expect(response).to redirect_to(providers_legal_aid_application_income_summary_index_path(application))
          end
        end

        context 'invalid params' do
          let(:employment_information_details) { '' }

          it 'displays error' do
            expect(response.body).to include(I18n.t('activemodel.errors.models.legal_aid_application.attributes.employment_information_details.blank'))
          end

          context 'no params' do
            let(:extra_employment_information) { '' }

            it 'displays error' do
              expect(unescaped_response_body).to include(I18n.t('activemodel.errors.models.legal_aid_application.attributes.extra_employment_information.blank'))
            end
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
            expect(application.extra_employment_information).to eq true
            expect(application.employment_information_details).to_not be_empty
          end

          it 'redirects to the list of applications' do
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end
      end
    end
  end
end
