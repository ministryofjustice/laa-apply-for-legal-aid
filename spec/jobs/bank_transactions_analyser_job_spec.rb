require 'rails_helper'

module Banking
  RSpec.describe BankTransactionsAnalyserJob, type: :job do
    let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :analysing_bank_transactions }
    let(:provider_email_service) { double(ProviderEmailService, send_email: true) }

    before do
      allow(BankTransactionBalanceCalculator).to receive(:call).with(legal_aid_application)
      allow(BankTransactionsTrimmer).to receive(:call).with(legal_aid_application)
      allow(StateBenefitAnalyserService).to receive(:call).with(legal_aid_application)
      allow(ProviderEmailService).to receive(:new).with(legal_aid_application).and_return(provider_email_service)
    end

    subject { described_class.perform_now(legal_aid_application) }

    describe '#perform' do
      it 'calls the BankTransactionBalanceCalculator' do
        expect(BankTransactionBalanceCalculator).to receive(:call).with(legal_aid_application)
        subject
      end

      it 'calls the BankTransactionTrimmer' do
        expect(BankTransactionsTrimmer).to receive(:call).with(legal_aid_application)
        subject
      end

      it 'calls the StateBenefitAnalyserService' do
        expect(StateBenefitAnalyserService).to receive(:call).with(legal_aid_application)
        subject
      end

      it 'updates the state' do
        allow(StateBenefitAnalyserService).to receive(:call).with(legal_aid_application)
        subject
        expect(legal_aid_application.reload.state).to eq('provider_assessing_means')
      end

      context 'transactions analysis' do
        context 'pending' do
          before do
            allow_any_instance_of(NonPassportedStateMachine).to receive(:aasm_state).and_return('analysing_bank_transactions')
          end

          it 'does not call ProviderEmailService' do
            expect(provider_email_service).not_to receive(:send_email)
            subject
          end
        end
        context 'complete' do
          it 'calls ProviderEmailService' do
            expect(provider_email_service).to receive(:send_email)
            subject
          end
        end
      end
    end
  end
end
