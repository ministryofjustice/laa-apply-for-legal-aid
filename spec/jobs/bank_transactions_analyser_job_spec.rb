require 'rails_helper'

RSpec.describe BankTransactionsAnalyserJob, type: :job do
  let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :analysing_bank_transactions }
  subject { described_class.perform_now(legal_aid_application) }

  describe '#perform' do
    it 'calls the StateBenefitAnalyserService' do
      expect(StateBenefitAnalyserService).to receive(:call).with(legal_aid_application)
      subject
    end

    it 'updates the state' do
      allow(StateBenefitAnalyserService).to receive(:call).with(legal_aid_application)
      subject
      expect(legal_aid_application.reload.state).to eq('provider_assessing_means')
    end
  end
end
