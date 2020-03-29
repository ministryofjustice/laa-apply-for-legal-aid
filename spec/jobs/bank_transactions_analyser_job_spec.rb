require 'rails_helper'

RSpec.describe BankTransactionsAnalyserJob, type: :job do
  let(:legal_aid_application) { create :legal_aid_application, :checking_passported_answers }
  subject { described_class.perform_now(legal_aid_application) }

  describe '#perform' do
    it 'calls BankTransactionsAnalyser and updates the state' do
      subject
      expect(legal_aid_application.reload.state).to eq('analysing_bank_transactions')
    end
  end
end
