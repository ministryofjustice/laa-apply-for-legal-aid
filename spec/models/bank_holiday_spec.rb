require "rails_helper"

RSpec.describe BankHoliday, vcr: { cassette_name: "gov_uk_bank_holiday_api", allow_playback_repeats: true } do
  let(:api_dates) { BankHolidayRetriever.dates }
  let!(:bank_holiday) { create(:bank_holiday) }

  describe ".dates" do
    it "returns dates from instance" do
      expect(described_class.dates).to eq(bank_holiday.dates)
    end

    context "without an existing instances" do
      before { described_class.delete_all }

      it "creates a new instance" do
        expect { described_class.dates }.to change(described_class, :count).from(0).to(1)
      end

      it "returns api dates" do
        expect(described_class.dates).to eq(api_dates)
      end

      it "does not create duplicates" do
        expect {
          described_class.dates
          described_class.dates
        }.to change(described_class, :count).from(0).to(1)
      end
    end
  end
end
