require 'rails_helper'

RSpec.describe 'ProceedingType factory' do
  context 'with a newly created service level' do
    it 'creates a new service level and assigns it to the proceeding type' do
      pt = create :proceeding_type
      expect(pt.default_level_of_service).to be_instance_of(ServiceLevel)
    end
  end

  context 'with real data' do
    it 'is associated with service level 3' do
      pt = create :proceeding_type, :with_real_data
      service_level = pt.default_level_of_service
      expect(service_level.service_level_number).to eq 3
    end

    it 'uses an existing level 3 if one exists' do
      service_level = create :service_level, :with_real_data
      pt = create :proceeding_type, :with_real_data
      expect(pt.default_level_of_service).to eq service_level
    end
  end
end
