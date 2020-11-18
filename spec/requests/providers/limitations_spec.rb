require 'rails_helper'

RSpec.describe Providers::LimitationsController, type: :request do
  let!(:proceeding_type) { create :proceeding_type }
  let(:legal_aid_application) { create :legal_aid_application, :with_substantive_scope_limitation, proceeding_types: [proceeding_type] }
  let(:provider) { legal_aid_application.provider }

  describe 'GET /providers/applications/:id/limitations' do
    subject { get providers_legal_aid_application_limitations_path(legal_aid_application) }

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
        expect(unescaped_response_body).to include(I18n.t('providers.limitations.show.h1-heading'))
      end
    end

    context '#pre_dwp_check?' do
      it 'returns true' do
        expect(described_class.new.pre_dwp_check?).to be true
      end
    end
  end

  describe 'PATCH /providers/applications/:id/limitations' do
    subject { patch providers_legal_aid_application_limitations_path(legal_aid_application) }

    before do
      login_as provider
    end

    it 'redirects to next page' do
      expect(subject).to redirect_to(providers_legal_aid_application_check_provider_answers_path(legal_aid_application))
    end
  end
end
