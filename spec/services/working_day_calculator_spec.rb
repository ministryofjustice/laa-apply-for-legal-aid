require "rails_helper"

RSpec.describe WorkingDayCalculator, vcr: { cassette_name: "gov_uk_bank_holiday_api" } do
  let(:day) { Date.parse("16-Dec-2025") }
  let(:working_day) { described_class.new(day) }

  let(:three_working_days_later) { Date.parse("19-Dec-2025") } # No skip
  let(:four_working_days_later) { Date.parse("22-Dec-2025") } # Weekend skip
  let(:seven_working_days_later) { Date.parse("29-Dec-2025") } # Weekend and bank holiday skip
  let(:two_working_days_before) { Date.parse("12-Dec-2025") } # Go backwards by two working days and skip weekend

  let(:number_to_target_dates) do
    {
      3 => three_working_days_later,
      4 => four_working_days_later,
      7 => seven_working_days_later,
      -2 => two_working_days_before,
    }
  end

  describe "#working_days_from_now" do
    it "returns expected dates" do
      number_to_target_dates.each do |number, date|
        expect(working_day.working_days_from_date(number)).to eq(date)
      end
    end

    context "with no date" do
      let(:day) { nil }

      it "raises an error if no date" do
        expect { working_day.working_days_from_date(3) }.to raise_error(WorkingDayCalculator::ParameterError)
      end
    end
  end

  describe ".working_days_from_now" do
    let(:day) { Time.zone.today }
    let(:number) { 12 }

    it "returns the date `n` days from today" do
      result = described_class.working_days_from_now(number)
      expected = working_day.add_working_days(number)
      expect(result).to eq(expected)
    end
  end

  describe ".call" do
    it "returns expected dates" do
      number_to_target_dates.each do |number, date|
        result = described_class.call working_days: number, from: day
        expect(result).to eq(date)
      end
    end
  end
end
