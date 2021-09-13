require 'rails_helper'

RSpec.describe DefaultCostLimitation do
  let(:pt) { create :proceeding_type }

  context 'enum' do
    it 'does not allow invalid cost types' do
      expect {
        DefaultCostLimitation.create!(proceeding_type: pt, cost_type: 'xxxx', start_date: 1.month.ago, value: 55)
      }.to raise_error ArgumentError, "'xxxx' is not a valid cost_type"
    end
  end

  describe 'for_date' do
    let(:old_start_date) { Date.parse('1970-01-01') }
    let(:new_start_date) { Date.parse('2021-09-13') }

    before { pt }

    context 'before change date' do
      let(:date) { Date.parse('2021-09-12') }
      it 'returns the old value' do
        dcl = DefaultCostLimitation.delegated_functions.for_date(date)
        expect(dcl.value).to eq 1350
      end
    end

    context 'on change date' do
      let(:date) { Date.parse('2021-09-13') }
      it 'returns the old value' do
        dcl = DefaultCostLimitation.delegated_functions.for_date(date)
        expect(dcl.value).to eq 2250
      end
    end

    context 'on change date' do
      let(:date) { Date.parse('2021-09-19') }
      it 'returns the old value' do
        dcl = DefaultCostLimitation.delegated_functions.for_date(date)
        expect(dcl.value).to eq 2250
      end
    end
  end
end
