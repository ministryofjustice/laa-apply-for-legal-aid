require 'rails_helper'

RSpec.describe Providers::OutstandingMortgagesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }

  describe 'provider outstanding mortgage test' do
    describe 'GET /providers/applications/:id/outstanding_mortgage' do
      before { get providers_legal_aid_application_outstanding_mortgage_path(legal_aid_application) }

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(CGI.escapeHTML("What is the outstanding mortgage on your client's home?"))
      end
    end
  end

  describe 'PATCH /providers/applications/:id/outstanding_mortgage', type: :request do
    let(:params) do
      {
        legal_aid_application: { outstanding_mortgage_amount: 321_654.87 },
        legal_aid_application_id: application.id,
        'continue-button' => 'Continue'
      }
    end

    context 'Submitted with the Continue button' do
      before { patch providers_legal_aid_application_outstanding_mortgage_path(application), params: params }

      context 'when an outstanding mortgage value is entered' do
        context 'with valid values' do
          let(:application) { legal_aid_application }

          it 'records the value in the legal aid application table' do
            legal_aid_application.reload
            expect(legal_aid_application.outstanding_mortgage_amount).to be_within(0.01).of(321_654.87)
            expect(legal_aid_application.updated_at.utc.to_i).to be_within(1).of(Time.now.to_i)
          end

          it 'redirects to the shared ownership page' do
            expect(response).to redirect_to providers_legal_aid_application_shared_ownership_path(application)
          end
        end
      end

      context 'when an outstanding mortgage value is not entered' do
        let(:application) { legal_aid_application }
        let(:params) do
          {
            legal_aid_application: { outstanding_mortgage_amount: '' },
            legal_aid_application_id: application.id
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

    context 'Submitted with the Save as draft button' do
      before do
        params.delete('continue-button')
        params['draft-button'] = 'Save as draft'
        patch providers_legal_aid_application_outstanding_mortgage_path(application), params: params
      end

      context 'when an outstanding mortgage value is entered' do
        context 'with valid values' do
          let(:application) { legal_aid_application }

          it 'records the value in the legal aid application table' do
            legal_aid_application.reload
            expect(legal_aid_application.outstanding_mortgage_amount).to be_within(0.01).of(321_654.87)
            expect(legal_aid_application.updated_at.utc.to_i).to be_within(1).of(Time.now.to_i)
          end

          it 'displays the provider applications home page' do
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end
      end

      context 'when an outstanding mortgage value is not entered' do
        let(:application) { legal_aid_application }
        let(:params) do
          {
            legal_aid_application: { outstanding_mortgage_amount: '' },
            legal_aid_application_id: application.id
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
