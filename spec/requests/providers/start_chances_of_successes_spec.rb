require 'rails_helper'

RSpec.describe Providers::StartChancesOfSuccessesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:provider) { legal_aid_application.provider }

  describe 'GET /providers/applications/:id/start_chances_of_success' do
    subject { get providers_legal_aid_application_start_chances_of_success_path(legal_aid_application) }

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
        expect(response.body).to include('Provide details of the case')
      end

      it 'displays do merits of case qualify list' do
        I18n.t('.providers.start_chances_of_successes.show.do_merits_of_case_qualify_list.list').each_line do |item|
          expect(response.body).to include(item)
        end
      end
    end
  end

  describe 'PATCH /providers/applications/:id/start_chances_of_success' do
    subject { patch providers_legal_aid_application_start_chances_of_success_path(legal_aid_application), params: params.merge(submit_button) }
    let(:params) { {} }

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      context 'Continue button pressed' do
        let(:submit_button) { { continue_button: 'Continue' } }
        it 'redirects to next page' do
          expect(subject).to redirect_to(providers_legal_aid_application_date_client_told_incident_path)
        end
      end

      context 'Save as draft button pressed' do
        let(:submit_button) { { draft_button: 'Save as draft' } }

        it "redirects provider to provider's applications page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it 'sets the application as draft' do
          expect(legal_aid_application.reload).to be_draft
        end
      end
    end
  end
end
