require 'rails_helper'

RSpec.describe Providers::ApplicantBankAccountsController, type: :request do
  let(:applicant) { create :applicant }
  let!(:bank_provider) { create :bank_provider, applicant: applicant }
  let!(:bank_account) { create :bank_account, bank_provider: bank_provider }
  let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :with_savings_amount, applicant: applicant }
  let!(:savings_amount) { create :savings_amount }
  let(:application_id) { legal_aid_application.id }
  let!(:provider) { legal_aid_application.provider }

  describe 'GET providers/applicant_bank_account' do
    subject { get providers_legal_aid_application_applicant_bank_account_path(legal_aid_application.id) }

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
        expect(unescaped_response_body).to include(I18n.t('providers.applicant_bank_accounts.show.heading'))
        expect(unescaped_response_body).to include(I18n.t('providers.applicant_bank_accounts.show.offline_savings_accounts'))
      end

      it 'shows the client bank account name and balance' do
        subject
        expect(unescaped_response_body).to include(bank_provider.name)
        expect(response.body).to include(bank_account.balance.to_s(:delimited))
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/does-client-use-online-banking' do
    let(:applicant_bank_account) { 'true' }
    let(:submit_button) { {} }
    let(:params) do
      {
        binary_choice_form: {
          applicant_bank_account: applicant_bank_account
        }
      }
    end

    subject do
      patch(
        "/providers/applications/#{application_id}/applicant_bank_account",
        params: params.merge(submit_button)
      )
    end

    context 'the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      it 'redirects to the non-passported offline savings account' do
        expect(response).to redirect_to(providers_legal_aid_application_offline_savings_account_path(legal_aid_application))
      end

      context 'neither option is chosen' do
        let(:params) { {} }

        it 'shows an error' do
          expect(unescaped_response_body).to include(I18n.t('providers.applicant_bank_accounts.show.error'))
        end
      end

      context 'The NO option is chosen' do
        let(:applicant_bank_account) { 'false' }

        it 'redirects to the savings and investments page' do
          expect(response).to redirect_to(providers_legal_aid_application_savings_and_investment_path(legal_aid_application))
        end
      end
    end
  end
end
