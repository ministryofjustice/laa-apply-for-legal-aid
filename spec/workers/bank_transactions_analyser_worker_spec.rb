require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe BankTransactionsAnalyserWorker, type: :worker do
  let(:legal_aid_application) { create :legal_aid_application, :analysing_bank_transactions }
  let(:subject) { described_class.perform_async(legal_aid_application.id) }
  let(:worker) { { 'status' => 'completed' } }

  before do
    allow(StateBenefitAnalyserService).to receive(:call)
  end

  describe '#perform' do
    it 'adds jobs to sidekiq' do
      expect { subject }.to change(described_class.jobs, :size).by(1)
    end
    it 'calls the StateBenefitAnalyserService' do
      described_class.clear
      expect(StateBenefitAnalyserService).to receive(:call).with(legal_aid_application)
      subject
      described_class.drain
    end
  end
end
