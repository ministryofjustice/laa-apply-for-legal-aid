require 'rails_helper'

RSpec.describe Providers::NoOutgoingsSummariesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine }
  let(:application_id) { legal_aid_application.id }
  let!(:provider) { legal_aid_application.provider }

  describe 'GET providers/no_outgoings_summary' do
    subject { get providers_legal_aid_application_no_outgoings_summary_path(legal_aid_application.id) }

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
        expect(unescaped_response_body).to include(I18n.t('providers.no_outgoings_summaries.show.page_heading'))
        expect(unescaped_response_body).to include(I18n.t('providers.no_outgoings_summaries.show.subheading.text'))
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/no_outgoings_summary' do
    let(:confirm_no_outgoings) { 'true' }
    let(:submit_button) { {} }
    let(:params) do
      {
        binary_choice_form: {
          no_outgoings_summaries: confirm_no_outgoings
        }
      }
    end

    subject do
      patch(
        "/providers/applications/#{application_id}/no_outgoings_summary",
        params: params.merge(submit_button)
      )
    end

    context 'the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      it 'redirects to the dependants' do
        expect(response).to redirect_to(providers_legal_aid_application_own_home_path(legal_aid_application))
      end

      context 'neither option is chosen' do
        let(:params) { {} }

        it 'shows an error' do
          expect(unescaped_response_body).to include(I18n.t('providers.no_outgoings_summaries.show.error'))
        end
      end

      context 'The NO option is chosen' do
        let(:confirm_no_outgoings) { 'false' }

        it 'redirects to the identify outgoings types page' do
          expect(response).to redirect_to(providers_legal_aid_application_identify_types_of_outgoing_path(legal_aid_application))
        end
      end
    end
  end
end
