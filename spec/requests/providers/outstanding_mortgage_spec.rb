require 'rails_helper'

RSpec.describe Providers::OutstandingMortgagesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:provider) { legal_aid_application.provider }
  let(:params) do
    {
      legal_aid_application: { outstanding_mortgage_amount: outstanding_mortgage_amount },
      legal_aid_application_id: legal_aid_application.id
    }
  end

  describe 'GET /providers/applications/:id/outstanding_mortgage' do
    subject { get providers_legal_aid_application_outstanding_mortgage_path(legal_aid_application) }

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
        expect(unescaped_response_body).to include("What is the outstanding mortgage on your client's home?")
      end
    end
  end

  describe 'PATCH /providers/applications/:id/outstanding_mortgage', type: :request do
    subject { patch providers_legal_aid_application_outstanding_mortgage_path(legal_aid_application), params: params.merge(submit_button) }

    let(:submit_button) do
      { continue_button: 'Continue' }
    end

    let(:outstanding_mortgage_amount) { '321,654.87' }

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      context 'Submitted with the Continue button' do
        context 'when an outstanding mortgage value is entered' do
          context 'with valid values' do
            it 'records the value in the legal aid application table' do
              legal_aid_application.reload
              expect(legal_aid_application.outstanding_mortgage_amount).to be_within(0.01).of(321_654.87)
            end

            it 'redirects to the shared ownership page' do
              expect(response).to redirect_to providers_legal_aid_application_shared_ownership_path(legal_aid_application)
            end
          end
        end

        context 'when an outstanding mortgage value is not entered' do
          let(:outstanding_mortgage_amount) { '' }

          it 'shows an error message' do
            expect(response.body).to include('govuk-error-summary__title')
          end

          it 'does not record the value in the legal aid application table' do
            legal_aid_application.reload
            expect(legal_aid_application.outstanding_mortgage_amount).to be nil
          end
        end
      end

      context 'Submitted with the Save as draft button' do
        let(:submit_button) do
          {
            draft_button: 'Save as draft'
          }
        end

        let(:outstanding_mortgage_amount) { '321,654.87' }

        context 'when an outstanding mortgage value is entered' do
          context 'with valid values' do
            it 'records the value in the legal aid application table' do
              legal_aid_application.reload
              expect(legal_aid_application.outstanding_mortgage_amount).to be_within(0.01).of(321_654.87)
            end

            it 'displays the provider applications home page' do
              expect(response).to redirect_to providers_legal_aid_applications_path
            end
          end
        end

        context 'when an outstanding mortgage value is not entered' do
          let(:params) do
            {
              legal_aid_application: { outstanding_mortgage_amount: '' },
              legal_aid_application_id: legal_aid_application.id
            }
          end

          it 'displays the provider applications home page' do
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end

        context 'when an invalid amount is entered' do
          let(:params) do
            {
              legal_aid_application: { outstanding_mortgage_amount: 'invalid' },
              legal_aid_application_id: legal_aid_application.id
            }
          end

          it 'shows an error message' do
            expect(response.body).to include('govuk-error-summary__title')
          end

          it 'does not record the value in the legal aid application table' do
            legal_aid_application.reload
            expect(legal_aid_application.outstanding_mortgage_amount).to be nil
          end
        end
      end
    end
  end
end
