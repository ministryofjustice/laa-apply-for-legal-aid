require "rails_helper"

module Banking
  RSpec.describe BankTransactionsAnalyserJob do
    subject(:bank_transaction_analyser_job) { described_class.perform_now(legal_aid_application) }

    let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, :analysing_bank_transactions) }
    let(:provider_email_service) { instance_double(ProviderEmailService, send_email: true) }

    before do
      allow(BankTransactionBalanceCalculator).to receive(:call).with(legal_aid_application)
      allow(BankTransactionsTrimmer).to receive(:call).with(legal_aid_application)
      allow(ProviderEmailService).to receive(:new).with(legal_aid_application).and_return(provider_email_service)
    end

    describe "#perform" do
      it "calls the BankTransactionBalanceCalculator" do
        expect(BankTransactionBalanceCalculator).to receive(:call).with(legal_aid_application)
        bank_transaction_analyser_job
      end

      it "calls the BankTransactionTrimmer" do
        expect(BankTransactionsTrimmer).to receive(:call).with(legal_aid_application)
        bank_transaction_analyser_job
      end

      it "updates the state" do
        bank_transaction_analyser_job
        expect(legal_aid_application.reload.state).to eq("provider_assessing_means")
      end

      context "with transactions analysis" do
        context "when pending" do
          before do
            allow(legal_aid_application.state_machine).to receive(:aasm_state).and_return("analysing_bank_transactions")
          end

          it "does not call ProviderEmailService" do
            expect(provider_email_service).not_to receive(:send_email)
            bank_transaction_analyser_job
          end
        end

        context "when complete" do
          it "calls ProviderEmailService" do
            expect(provider_email_service).to receive(:send_email)
            bank_transaction_analyser_job
          end
        end
      end
    end
  end
end
