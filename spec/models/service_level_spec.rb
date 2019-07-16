require 'rails_helper'

RSpec.describe ServiceLevel, type: :model do
  describe '.populate' do
    it 'calls the service_level_populator service' do
      expect(ServiceLevelPopulator).to receive(:call).with(no_args)
      described_class.populate
    end
  end
end
