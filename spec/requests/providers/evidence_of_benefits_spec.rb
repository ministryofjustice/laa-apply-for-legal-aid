require 'rails_helper'

RSpec.describe Providers::EvidenceOfBenefitsController, type: :request do
  let(:application) { create(:legal_aid_application, :with_proceeding_types, :with_applicant_and_address) }
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/evidence_of_benefit' do
    subject { get "/providers/applications/#{application_id}/evidence_of_benefit" }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as application.provider
        subject
      end

      it 'returns success' do
        expect(response).to be_successful
      end

      it 'displays the correct page' do
        expect(unescaped_response_body).to include('evidence_of_benefit page under construction')
      end
    end
  end
end
