require 'rails_helper'

RSpec.describe ScopeLimitation, type: :model do
  describe '.populate' do
    it 'calls the scope_limitations_populator service' do
      expect(ScopeLimitationsPopulator).to receive(:call).with(no_args)
      described_class.populate
    end
  end
end
