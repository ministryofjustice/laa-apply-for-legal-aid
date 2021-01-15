require 'rails_helper'

RSpec.describe TrueLayerBanksUpdateWorker, vcr: { cassette_name: 'true_layer_banks_api', allow_playback_repeats: true } do
  let(:true_layer_banks_update_worker) { described_class.new }
  let(:stale_date) { Time.current.utc - described_class::UPDATE_INTERVAL - 2.hours }
  let!(:true_layer_bank) { create :true_layer_bank }

  subject { true_layer_banks_update_worker.perform }

  it 'returns true' do
    expect(subject).to be true
  end

  it 'does not change the true_layer_bank object' do
    expect { subject }.not_to change { true_layer_bank.reload }
  end

  it 'does not create a new true_layer_bank object' do
    expect { subject }.not_to change { TrueLayerBank.count }
  end

  context 'when outdated' do
    let!(:true_layer_bank) { create :true_layer_bank, updated_at: stale_date }

    it 'creates a new bank holiday instance' do
      expect { subject }.to change { TrueLayerBank.count }.by(1)
    end
  end

  context 'when outdated has current data' do
    let!(:true_layer_bank) { TrueLayerBank.create!(updated_at: stale_date) }

    it 'does not create a new true_layer_bank object' do
      expect { subject }.not_to change { TrueLayerBank.count }
    end

    it 'touches the existing true_layer_bank object' do
      subject
      expect(true_layer_bank.reload.updated_at).to be_between(2.seconds.ago, 1.second.from_now)
    end
  end

  context 'when data retrieval fails' do
    let!(:true_layer_bank) { create :true_layer_bank, updated_at: stale_date }

    it 'raises error' do
      allow(TrueLayer::BanksRetriever).to receive(:banks).and_raise(TrueLayer::BanksRetriever::UnsuccessfulRetrievalError)
      expect { subject }.to raise_error(TrueLayer::BanksRetriever::UnsuccessfulRetrievalError)
    end
  end
end
