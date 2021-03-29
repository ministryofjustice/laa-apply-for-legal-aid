require 'rails_helper'

RSpec.describe Providers::NoIncomeSummariesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine }
  let(:application_id) { legal_aid_application.id }
  let!(:provider) { legal_aid_application.provider }

  describe 'GET providers/no_income_summary' do
    subject { get providers_legal_aid_application_no_income_summary_path(legal_aid_application.id) }

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
        expect(response).to have_http_status(:success)
      end

      it 'displays the correct page content' do
        expect(unescaped_response_body).to include(I18n.t('providers.no_income_summaries.show.page_heading'))
        expect(unescaped_response_body).to include(I18n.t('providers.no_income_summaries.show.subheading.text'))
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/no_income_summary' do
    let(:no_income_summaries) { 'true' }
    let(:submit_button) { {} }
    let(:params) do
      {
        binary_choice_form: {
          no_income_summaries: no_income_summaries
        }
      }
    end

    subject do
      patch(
        "/providers/applications/#{application_id}/no_income_summary",
        params: params.merge(submit_button)
      )
    end

    context 'the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      it 'redirects to the dependants' do
        expect(response).to redirect_to(providers_legal_aid_application_has_dependants_path(legal_aid_application))
      end

      context 'neither option is chosen' do
        let(:params) { {} }

        it 'shows an error' do
          expect(unescaped_response_body).to include(I18n.t('providers.no_income_summaries.show.error'))
        end
      end

      context 'The NO option is chosen' do
        let(:no_income_summaries) { 'false' }

        it 'redirects to the identify income types page' do
          expect(response).to redirect_to(providers_legal_aid_application_identify_types_of_income_path(legal_aid_application))
        end
      end
    end
  end
end
