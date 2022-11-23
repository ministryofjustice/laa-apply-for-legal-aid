require "rails_helper"

RSpec.describe AgeCalculator do
  subject { described_class.call(date_of_birth, date) }

  let(:date_of_birth) { Date.parse("15-08-2000") }

  context "when date is 1 day after birthday" do
    let(:date) { Date.parse("16-08-2010") }

    it { is_expected.to eq(10) }
  end

  context "when date is 1 day before birthday" do
    let(:date) { Date.parse("14-08-2010") }

    it { is_expected.to eq(9) }
  end

  context "when date is same day as birthday" do
    let(:date) { Date.parse("15-08-2010") }

    it { is_expected.to eq(10) }
  end

  context "when birthday is on 29th of February" do
    let(:date_of_birth) { Date.parse("29-02-2000") }

    context "with date of 29th Ferbuary in a leap year" do
      let(:date) { Date.parse("29-02-2012") }

      it { is_expected.to eq(12) }
    end

    context "with date of 28th Ferbuary in a leap year" do
      let(:date) { Date.parse("28-02-2012") }

      it { is_expected.to eq(11) }
    end

    context "with date of 28th February in a non-leap year" do
      let(:date) { Date.parse("28-02-2010") }

      it { is_expected.to eq(9) }
    end

    context "with date of 1st March in a non-leap year" do
      let(:date) { Date.parse("01-03-2010") }

      it { is_expected.to eq(10) }
    end
  end
end
