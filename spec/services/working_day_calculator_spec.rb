require 'rails_helper'

RSpec.describe WorkingDayCalculator, vcr: { cassette_name: 'gov_uk_bank_holiday_api' } do
  let(:day) { Date.parse('17-Dec-2018') }
  let(:three_working_days_later) { Date.parse('20-Dec-2018') } # No skip
  let(:five_working_days_later) { Date.parse('24-Dec-2018') } # Weekend skip
  let(:six_working_days_later) { Date.parse('27-Dec-2018') } # Weekend and bank holiday skip
  let(:two_working_days_before) { Date.parse('13-Dec-2018') } # Go backwards by two working days and skip weekend
  let(:number_to_target_dates) do
    {
      3 => three_working_days_later,
      5 => five_working_days_later,
      6 => six_working_days_later,
      -2 => two_working_days_before
    }
  end
  let(:working_day) { described_class.new(day) }

  describe '#working_days_from_now' do
    it 'returns expected dates' do
      number_to_target_dates.each do |number, date|
        expect(working_day.working_days_from_date(number)).to eq(date)
      end
    end

    context 'with no date' do
      let(:day) { nil }

      it 'raises an error if no date' do
        expect { working_day.working_days_from_date(3) }.to raise_error(WorkingDayCalculator::ParameterError)
      end
    end
  end

  describe '.working_days_from_now' do
    let(:day) { Time.zone.today }
    let(:number) { 12 }

    it 'returns the date `n` days form today' do
      result = described_class.working_days_from_now(number)
      expected = working_day.add_working_days(number)
      expect(result).to eq(expected)
    end
  end

  describe '.call' do
    it 'returns expected dates' do
      number_to_target_dates.each do |number, date|
        result = described_class.call working_days: number, from: day
        expect(result).to eq(date)
      end
    end
  end
end
