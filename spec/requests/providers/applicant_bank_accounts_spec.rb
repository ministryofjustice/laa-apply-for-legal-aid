require 'rails_helper'

RSpec.describe Providers::ApplicantBankAccountsController, type: :request do
  let(:applicant) { create :applicant }
  let!(:bank_provider) { create :bank_provider, applicant: applicant }
  let!(:bank_account) { create :bank_account, bank_provider: bank_provider }
  let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :with_savings_amount, applicant: applicant }
  let!(:savings_amount) { create :savings_amount }
  let(:application_id) { legal_aid_application.id }
  let!(:provider) { legal_aid_application.provider }

  describe 'GET providers/:application_id/applicant_bank_account' do
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

  describe 'PATCH /providers/applications/:application_id/applicant_bank_account' do
    let(:applicant_bank_account) { 'false' }
    let(:offline_savings_accounts) { rand(1...1_000_000.0).round(2) }
    let(:params) do
      {
        savings_amount: {
          applicant_bank_account: applicant_bank_account,
          offline_savings_accounts: offline_savings_accounts
        }
      }
    end

    subject do
      patch(
        "/providers/applications/#{application_id}/applicant_bank_account",
        params: params
      )
    end

    context 'the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      context 'neither option is chosen' do
        let(:applicant_bank_account) { nil }

        it 'shows an error' do
          expect(unescaped_response_body).to include(I18n.t('errors.applicant_bank_accounts.blank'))
        end
      end

      context 'The NO option is chosen' do
        let(:applicant_bank_account) { 'false' }

        it 'resets the account balance' do
          expect(legal_aid_application.savings_amount[:offline_savings_account]).to be_nil
        end

        it 'redirects to the savings and investments page' do
          expect(response).to redirect_to(providers_legal_aid_application_savings_and_investment_path(legal_aid_application))
        end
      end

      context 'The YES option is chosen' do
        let(:applicant_bank_account) { 'true' }

        context 'no amount is entered' do
          let(:offline_savings_accounts) { '' }

          it 'displays the correct error' do
            expect(unescaped_response_body).to include(I18n.t('activemodel.errors.models.savings_amount.attributes.offline_savings_accounts.blank'))
          end
        end

        context 'an invalid input is entered' do
          let(:offline_savings_accounts) { 'abc' }

          it 'displays the correct error' do
            expect(unescaped_response_body).to include(I18n.t('activemodel.errors.models.savings_amount.attributes.offline_savings_accounts.not_a_number'))
          end
        end

        context 'a valid savings amount is entered' do
          let(:offline_savings_accounts) { rand(1...1_000_000.0).round(2) }

          it 'redirects to the savings and investments page' do
            expect(response).to redirect_to(providers_legal_aid_application_savings_and_investment_path(legal_aid_application))
          end
        end
      end
    end
  end
end
