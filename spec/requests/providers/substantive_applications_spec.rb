require 'rails_helper'
RSpec.describe Providers::UsedDelegatedFunctionsController, type: :request, vcr: { cassette_name: 'gov_uk_bank_holiday_api' } do
  let(:legal_aid_application) { create :legal_aid_application, state: :client_details_answers_checked }
  let(:login_provider) { login_as legal_aid_application.provider }

  before do
    login_provider
    subject
  end

  describe 'GET /providers/applications/:legal_aid_application_id/substantive_application' do
    subject do
      get providers_legal_aid_application_substantive_application_path(legal_aid_application)
    end

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    context 'when not authenticated' do
      let(:login_provider) { nil }
      it_behaves_like 'a provider not authenticated'
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/substantive_application' do
    let(:substantive_application) { true }
    let(:params) do
      {
        legal_aid_application: {
          substantive_application: substantive_application.to_s
        }
      }
    end
    let(:button_clicked) { {} }

    subject do
      patch(
        providers_legal_aid_application_substantive_application_path(legal_aid_application),
        params: params.merge(button_clicked)
      )
    end

    it 'updates the application' do
      legal_aid_application.reload
      expect(legal_aid_application.substantive_application).to eq(substantive_application)
      expect(legal_aid_application.substantive_application_deadline_on).to be_nil
      expect(legal_aid_application.state).to eq('delegated_functions_used')
    end

    it 'redirects to online banking' do
      expect(response).to redirect_to(
        providers_legal_aid_application_online_banking_path(legal_aid_application)
      )
    end

    context 'with positive benefit check' do
      let(:legal_aid_application) do
        create(
          :legal_aid_application,
          :with_positive_benefit_check_result,
          state: :client_details_answers_checked
        )
      end

      it 'redirects to captial introductions' do
        expect(response).to redirect_to(
          providers_legal_aid_application_capital_introduction_path(legal_aid_application)
        )
      end
    end

    context 'No selected' do
      let(:substantive_application) { false }

      it 'updates the application' do
        legal_aid_application.reload
        expect(legal_aid_application.substantive_application).to eq(substantive_application)
        expect(legal_aid_application.substantive_application_deadline_on).to be_present
        expect(legal_aid_application.state).to eq('delegated_functions_used')
      end

      it 'redirects to online banking' do
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end
    end

    context 'when not authenticated' do
      let(:login_provider) { nil }
      it_behaves_like 'a provider not authenticated'
    end

    context 'with nothing selected' do
      let(:substantive_application) { '' }

      it 'renders show' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays error' do
        expect(response.body).to include('govuk-error-summary')
        expect(response.body).to include('Select Yes or No')
      end
    end
  end
end
