require 'rails_helper'

RSpec.describe Restriction, type: :model do
  describe '.populate' do
    subject { described_class.populate }
    let(:names) { described_class::NAMES }

    it 'create instances from names' do
      expect { subject }.to change { described_class.count }.by(names.length)
    end

    it 'creates instances with names from NAMES' do
      subject
      expect(described_class.pluck(:name).map(&:to_sym)).to match_array(names)
    end

    context 'when a restriction exists' do
      let!(:restriction) { create :restriction, :with_standard_name }
      it 'creates one less restriction' do
        expect { subject }.to change { described_class.count }.by(names.length - 1)
      end
    end

    context 'when run twice' do
      it 'creates the same total number of instancees' do
        expect {
          subject
          subject
        }.to change { described_class.count }.by(names.length)
      end
    end
  end
end
