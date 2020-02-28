require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  describe '#purchased_on' do
    let(:vehicle) { create :vehicle, purchased_on: purchased_on, more_than_three_years_old: more_than_three_years_old }

    context 'purchased_on is populated' do
      let(:purchased_on) { 6.months.ago.to_date }
      let(:more_than_three_years_old) { nil }
      it 'returns the purchased on date' do
        expect(vehicle.purchased_on).to eq purchased_on
      end
    end

    context 'purchased_on is nil' do
      let(:purchased_on) { nil }

      context 'more than three years old' do
        let(:more_than_three_years_old) { true }
        it 'returns a date 4 years ago' do
          expect(vehicle.purchased_on).to eq 4.years.ago.to_date
        end
      end

      context 'less than three years old' do
        let(:more_than_three_years_old) { false }
        it 'returns a date 2 years ago' do
          expect(vehicle.purchased_on).to eq 2.years.ago.to_date
        end
      end
    end
  end
end
