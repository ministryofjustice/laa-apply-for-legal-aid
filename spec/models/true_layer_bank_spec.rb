require 'rails_helper'

RSpec.describe TrueLayerBank, type: :model, vcr: { cassette_name: 'true_layer_banks_api', allow_playback_repeats: true } do
  let(:api_banks) { TrueLayer::BanksRetriever.banks }
  let!(:true_layer_bank) { create :true_layer_bank }
  let(:enable_mock) { false }

  before do
    allow(Rails.configuration.x.true_layer).to receive(:enable_mock).and_return(enable_mock)
  end

  describe '.banks' do
    it 'returns banks from instance' do
      expect(described_class.banks).to eq(true_layer_bank.banks)
    end

    it 'triggers and update process' do
      expect(TrueLayerBanksUpdateWorker).to receive(:perform_in)
      described_class.banks
    end

    context 'without an existing instances' do
      let!(:true_layer_bank) { nil }

      before { described_class.delete_all }

      it 'creates a new instance' do
        expect { described_class.banks }.to change { described_class.count }.from(0).to(1)
      end

      it 'does not create duplicates' do
        expect {
          described_class.banks
          described_class.banks
        }.to change { described_class.count }.from(0).to(1)
      end

      it 'returns api banks' do
        expect(described_class.banks).to eq(api_banks)
      end

      context 'mock bank is enabled' do
        let(:enable_mock) { true }

        it 'returns mock bank + api banks' do
          expect(described_class.banks).to eq([described_class::MOCK_BANK] + api_banks)
        end
      end
    end
  end
end
