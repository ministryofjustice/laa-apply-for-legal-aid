require 'rails_helper'

RSpec.describe Providers::ConfirmMultipleDelegatedFunctionsController, type: :request do
  let!(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceeding_types }
  let(:login_provider) { login_as legal_aid_application.provider }

  before do
    login_provider
    subject
  end

  describe 'GET /providers/applications/:legal_aid_application_id/confirm_multiple_delegated_functions' do
    subject do
      get providers_legal_aid_application_confirm_multiple_delegated_functions_path(legal_aid_application)
    end

    it 'renders correctly' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH' do
    subject do
      patch providers_legal_aid_application_confirm_multiple_delegated_functions_path(legal_aid_application), params: params
    end

    let(:params) { { binary_choice_form: { confirm_multiple_delegated_functions_date: confirmation } } }

    context 'redirecting' do
      context 'when true' do
        let(:confirmation) { true }
        it 'redirects to limitations' do
          expect(response).to redirect_to(providers_legal_aid_application_limitations_path(legal_aid_application))
        end
      end

      context 'when false' do
        let(:confirmation) { false }
        it 'redirects back to the used multiple delegated functions page' do
          expect(response).to redirect_to(providers_legal_aid_application_used_multiple_delegated_functions_path(legal_aid_application))
        end
      end
    end

    context 'when nothing selected' do
      let(:confirmation) { nil }
      it 'error singular' do
        expect(response.body).to include(I18n.t("#{base_error_translation}.error.blank_singular"))
      end
      context 'when the legal aid app has multiple DF dates over a month' do
        let!(:legal_aid_application) do
          create :legal_aid_application,
                 :with_proceeding_types,
                 :with_delegated_functions,
                 proceeding_types_count: 2,
                 delegated_functions_date: [35.days.ago.to_date, 36.days.ago.to_date]
        end
        it 'error pluralised' do
          expect(response.body).to include(I18n.t("#{base_error_translation}.error.blank_plural"))
        end
      end
    end

    def base_error_translation
      'providers.confirm_multiple_delegated_functions_dates.show'
    end
  end
end
