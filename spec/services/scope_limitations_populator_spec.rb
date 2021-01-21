require 'rails_helper'
require 'csv'

RSpec.describe ScopeLimitationsPopulator do
  describe '#call' do
    let(:seed_file) { Rails.root.join('db/seeds/legal_framework/scope_limitations.csv') }

    it 'create instances from the seed file' do
      expect { described_class.call }.to change { ScopeLimitation.count }.by(seed_file.readlines.size - 1)
    end

    it 'creates instances with correct data from the seed file' do
      described_class.call
      expect(ScopeLimitation.order('created_at ASC').first.code).to eq(CSV.read(seed_file, headers: true)[0][0])
    end

    context 'when a scope_limitation exists' do
      let!(:scope_limitation) { create :scope_limitation, 'with_real_data' }
      it 'creates one less scope_limitation' do
        expect { described_class.call }.to change { ScopeLimitation.count }.by(seed_file.readlines.size - 2)
      end
    end

    context 'when run twice' do
      it 'creates the same total number of instances' do
        expect {
          described_class.call
          described_class.call
        }.to change { ScopeLimitation.count }.by(seed_file.readlines.size - 1)
      end
    end
  end
end
