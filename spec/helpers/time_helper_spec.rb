require 'rails_helper'

RSpec.describe TimeHelper, type: :helper do
  describe 'number_of_days_ago' do
    let(:days) { 2 }

    before do
      new_time = Time.zone.local(2020, 10, 1, 1, 0, 0)
      travel_to(new_time)
    end
    it 'returns a valid date' do
      expect(helper.number_of_days_ago(days)).to eq '29 09 2020'
    end
  end
end
