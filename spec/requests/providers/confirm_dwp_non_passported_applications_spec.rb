require 'rails_helper'

RSpec.describe Providers::ConfirmDWPNonPassportedApplicationsController, type: :request do
  let(:used_delegated_functions) { false }
  let(:used_delegated_functions_on) { nil }
  let(:address) { create :address }
  let(:applicant) { create :applicant, address: address }
  let(:application) do
    create(
      :legal_aid_application,
      :with_non_passported_state_machine,
      :at_entering_applicant_details,
      :with_proceeding_types,
      :with_substantive_scope_limitation,
      :with_delegated_functions_scope_limitation,
      used_delegated_functions: used_delegated_functions,
      used_delegated_functions_on: used_delegated_functions_on,
      applicant: applicant
    )
  end
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/confirm_dwp_non_passported_applications' do
    subject { get "/providers/applications/#{application_id}/confirm_dwp_non_passported_applications" }

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
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/confirm_dwp_non_passported_applications' do
    subject { patch "/providers/applications/#{application_id}/confirm_dwp_non_passported_applications" }

    before do
      login_as application.provider
      subject
    end

    context 'Continue' do
      it 'continues to the client details page' do
        subject
        expect(response).to redirect_to(providers_legal_aid_application_check_benefits_path(application))
      end
    end
  end
end
