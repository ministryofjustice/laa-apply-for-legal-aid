require 'rails_helper'

RSpec.describe TimeHelper, type: :helper do
  describe 'number_of_months_ago' do
    let(:months) { 2 }

    before do
      new_time = Time.local(2020, 10, 1, 1, 0, 0)
      Timecop.freeze(new_time)
    end
    it 'returns a valid date' do
      expect(helper.number_of_months_ago(months)).to eq '01 08 2020'
    end
  end
end
