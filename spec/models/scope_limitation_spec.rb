require 'rails_helper'
require 'csv'

RSpec.describe ScopeLimitation, type: :model do
  describe '.populate' do
    subject { described_class.populate }
    let(:seed_file) { Rails.root.join('db', 'seeds', 'scope_limitations.csv') }

    it 'create instances from the seed file' do
      expect { subject }.to change { described_class.count }.by(seed_file.readlines.size - 1)
    end

    it 'creates instances with correct data from the seed file' do
      subject
      expect(described_class.order("created_at ASC").first.code).to eq(CSV.read(seed_file, headers: true)[0][0])
    end

    context 'when a scope_limitation exists' do
      let!(:scope_limitation) { create :scope_limitation, 'with_real_data' }
      it 'creates one less scope_limitation' do
        expect { subject }.to change { described_class.count }.by(seed_file.readlines.size - 2)
      end
    end

    context 'when run twice' do
      it 'creates the same total number of instances' do
        expect {
          subject
          subject
        }.to change { described_class.count }.by(seed_file.readlines.size - 1)
      end
    end
  end
end
