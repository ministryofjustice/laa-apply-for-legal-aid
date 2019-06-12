require 'rails_helper'
RSpec.describe Providers::UsedDelegatedFunctionsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:login_provider) { login_as legal_aid_application.provider }

  before do
    login_provider
    subject
  end

  describe 'GET /providers/applications/:legal_aid_application_id/used_delegated_functions' do
    subject do
      get providers_legal_aid_application_used_delegated_functions_path(legal_aid_application)
    end

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    context 'when not authenticated' do
      let(:login_provider) { nil }
      it_behaves_like 'a provider not authenticated'
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/used_delegated_functions' do
    let(:used_delegated_functions_on) { rand(20).days.ago.to_date }
    let(:day) { used_delegated_functions_on.day }
    let(:month) { used_delegated_functions_on.month }
    let(:year) { used_delegated_functions_on.year }
    let(:params) do
      {
        legal_aid_application: {
          used_delegated_functions_day: day.to_s,
          used_delegated_functions_month: month.to_s,
          used_delegated_functions_year: year.to_s
        }
      }
    end
    let(:button_clicked) { {} }

    subject do
      patch(
        providers_legal_aid_application_used_delegated_functions_path(legal_aid_application),
        params: params.merge(button_clicked)
      )
    end

    it 'update the application' do
      expect(legal_aid_application.reload.used_delegated_functions_on).to eq(used_delegated_functions_on)
    end

    it 'redirects to the next page' do
      expect(response).to redirect_to(flow_forward_path)
    end

    context 'when not authenticated' do
      let(:login_provider) { nil }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when incomplete' do
      let(:month) { '' }

      it 'renders show' do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
