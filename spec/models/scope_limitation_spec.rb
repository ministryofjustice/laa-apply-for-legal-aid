require 'rails_helper'

RSpec.describe ScopeLimitation, type: :model do
  describe '.populate' do
    it 'calls the scope_limitations_populator service' do
      expect(ScopeLimitationsPopulator).to receive(:call).with(no_args)
      described_class.populate
    end
  end

  describe 'should have associations with scope_limitation' do
    it { should have_many(:proceeding_types) }
  end
end
