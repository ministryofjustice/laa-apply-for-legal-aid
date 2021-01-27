require 'rails_helper'
RSpec.describe Providers::DelegatedFunctionsDatesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:login_provider) { login_as legal_aid_application.provider }

  before do
    login_provider
    subject
  end

  describe 'GET /providers/applications/:legal_aid_application_id/delegated_functions_date' do
    subject do
      get providers_legal_aid_application_delegated_functions_date_path(legal_aid_application)
    end

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/delegated_functions_date' do
    let(:confirm_delegated_functions_date) { true }
    let(:used_delegated_functions_on) { rand(20).days.ago.to_date }
    let(:day) { used_delegated_functions_on.day }
    let(:month) { used_delegated_functions_on.month }
    let(:year) { used_delegated_functions_on.year }
    let(:params) do
      {
        legal_aid_application: {
          used_delegated_functions_day: day.to_s,
          used_delegated_functions_month: month.to_s,
          used_delegated_functions_year: year.to_s,
          confirm_delegated_functions_date: confirm_delegated_functions_date.to_s
        }
      }
    end
    let(:button_clicked) { {} }

    subject do
      patch(
        providers_legal_aid_application_delegated_functions_date_path(legal_aid_application),
        params: params.merge(button_clicked)
      )
    end

    it 'does not update the legal aid application' do
      legal_aid_application.reload
      expect(legal_aid_application.used_delegated_functions_on).to eq used_delegated_functions_on
    end

    it 'redirects to the limitations page' do
      # fill
    end

    context 'confirm_delegated_functions_date false' do
      # fill
    end
  end
end
