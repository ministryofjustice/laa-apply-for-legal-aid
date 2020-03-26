require 'rails_helper'

RSpec.describe BankTransactionsAnalyserJob, type: :job do
  let(:legal_aid_application) { create :legal_aid_application, :checking_passported_answers }
  subject { described_class.new.perform(legal_aid_application) }

  describe '#perform' do
    it 'calls BankTransactionsAnalyser and updates the state' do
      subject
      expect(legal_aid_application.state).to eq('provider_assessing_means')
    end
  end
end
