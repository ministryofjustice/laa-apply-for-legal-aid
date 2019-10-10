require 'rails_helper'

RSpec.describe TrueLayerBank, type: :model, vcr: { cassette_name: 'true_layer_banks_api', allow_playback_repeats: true } do
  let(:api_banks) { TrueLayer::BanksRetriever.banks }
  let!(:true_layer_bank) { create :true_layer_bank }
  let(:enable_mock) { false }

  before do
    allow(Rails.configuration.x.true_layer).to receive(:enable_mock).and_return(enable_mock)
  end

  describe '.available_banks' do
    it 'returns available_banks from instance' do
      expect(described_class.available_banks).to eq(true_layer_bank.available_banks)
    end

    it 'triggers and update process' do
      expect(TrueLayerBanksUpdateWorker).to receive(:perform_in)
      described_class.available_banks
    end

    context 'without an existing instances' do
      let!(:true_layer_bank) { nil }

      before { described_class.delete_all }

      it 'creates a new instance' do
        expect { described_class.available_banks }.to change { described_class.count }.from(0).to(1)
      end

      it 'does not create duplicates' do
        expect {
          described_class.available_banks
          described_class.available_banks
        }.to change { described_class.count }.from(0).to(1)
      end

      it 'returns api available_banks interesected with configured banks' do
        result = api_banks.select do |bank|
          bank[:provider_id].in?(Rails.configuration.x.true_layer.banks)
        end
        expect(described_class.available_banks).to eq(result)
      end

      context 'mock bank is enabled' do
        let(:enable_mock) { true }

        it 'includes mock bank' do
          expect(described_class.available_banks).to include(described_class::MOCK_BANK)
        end
      end
    end
  end
end
