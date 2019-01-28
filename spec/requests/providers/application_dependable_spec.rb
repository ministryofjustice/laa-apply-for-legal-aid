require 'rails_helper'

RSpec.describe 'Providers::ApplicationDependable' do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:provider) { legal_aid_application.provider }

  describe 'GET an action' do
    subject { get providers_legal_aid_application_proceedings_type_path(legal_aid_application) }

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
      end

      it 'records the current controller name' do
        expect(legal_aid_application.reload.provider_step).to eq('proceedings_types')
      end

      context 'with an invalid legal_aid_application' do
        subject { get providers_legal_aid_application_proceedings_type_path(invlaid_legal_aid_application) }

        let(:invlaid_legal_aid_application) { build :legal_aid_application, id: SecureRandom.uuid }
        it "redirects to provider's start page" do
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end
      end
    end
  end
end
