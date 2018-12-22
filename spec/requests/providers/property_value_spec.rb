require 'rails_helper'

RSpec.describe Providers::PropertyValuesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:secure_id) { legal_aid_application.generate_secure_id }

  describe 'provider property value test' do
    describe 'GET /providers/applications/:id/property_value' do
      before { get providers_legal_aid_application_property_value_path(legal_aid_application) }

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(CGI.escapeHTML("How much is your client's home worth?"))
      end
    end
  end

  describe 'PATCH /providers/applications/:id/property_value', type: :request do
    let(:params) do
      {
        legal_aid_application: { property_value: 123_456.78 },
        legal_aid_application_id: application.id
      }
    end

    before { patch providers_legal_aid_application_property_value_path(application), params: params }

    context 'when a property value is entered' do
      context 'property is mortgaged' do
        let(:application) { create :legal_aid_application, :with_applicant, :with_own_home_mortgaged }

        # TODO: replace with correct path once other controllers are ready
        xit 'redirects to the shared question' do
          # expect(response).to redirect_to shared_question_path
        end

        # TODO: remove once we can redirect to next controller
        it 'renders plain message' do
          expect(response.body).to eq 'Navigate to question 1c: Mortgage'
        end
      end

      context 'property is owned outright' do
        let(:application) { create :legal_aid_application, :with_applicant, :with_own_home_owned_outright }

        # TODO: replace with correct path once other controllers are ready
        xit 'redirects to the shared question' do
          # expect(response).to redirect_to mortgage_question_path
        end

        # TODO: remove once we can redirect to next controller
        it 'renders plain message' do
          expect(response.body).to eq 'Navigate to question 1d: Shared?'
        end
      end

      context 'with valid values' do
        let(:application) { legal_aid_application }

        it 'records the value in the legal aid application table' do
          legal_aid_application.reload
          expect(legal_aid_application.property_value).to be_within(0.01).of(123_456.78)
          expect(legal_aid_application.updated_at.utc.to_i).to be_within(1).of(Time.now.to_i)
        end
      end
    end

    context 'when a property value is not entered' do
      let(:application) { legal_aid_application }
      let(:params) do
        {
          legal_aid_application: { property_value: '' },
          legal_aid_application_id: application.id
        }
      end

      it 'shows an error message' do
        expect(response.body).to include('govuk-error-summary__title')
      end

      it 'does not record the value in the legal aid application table' do
        legal_aid_application.reload
        expect(legal_aid_application.property_value).to be nil
      end
    end
  end
end
