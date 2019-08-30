require 'rails_helper'
require 'csv'

RSpec.describe ServiceLevelPopulator do
  describe '#call' do
    let(:seed_file) { Rails.root.join('db/seeds/legal_framework/levels_of_service.csv') }

    it 'create instances from the seed file' do
      expect { described_class.call }.to change { ServiceLevel.count }.by(seed_file.readlines.size - 1)
    end

    it 'creates instances with correct data from the seed file' do
      described_class.call
      expect(ServiceLevel.order('created_at ASC').first.service_level_number.to_s).to eq(CSV.read(seed_file, headers: true)[0][0])
    end

    context 'when a service_level exists' do
      let!(:service_level) { create :service_level, :with_real_data }
      it 'creates one less service_level' do
        expect { described_class.call }.to change { ServiceLevel.count }.by(seed_file.readlines.size - 2)
      end
    end

    context 'when run twice' do
      it 'creates the same total number of instances' do
        expect {
          described_class.call
          described_class.call
        }.to change { ServiceLevel.count }.by(seed_file.readlines.size - 1)
      end
    end
  end
end
