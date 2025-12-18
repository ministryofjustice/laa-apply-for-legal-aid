require "rails_helper"

RSpec.describe BankHoliday, vcr: { cassette_name: "gov_uk_bank_holiday_api", allow_playback_repeats: true } do
  let(:api_dates) { BankHolidayRetriever.dates }
  let!(:bank_holiday) { create(:bank_holiday) }

  describe ".dates" do
    context "when bank holiday data already exists" do
      it "does not create a new record" do
        expect { described_class.dates }.not_to change(described_class, :count).from(1)
      end

      it "returns dates from the record" do
        expect(described_class.dates).to eq(bank_holiday.dates)
      end
    end

    context "when bank holiday data does not exist" do
      before do
        described_class.delete_all
        BankHolidayStore.destroy!
      end

      it "creates a new database record" do
        expect { described_class.dates }.to change(described_class, :count).from(0).to(1)
      end

      it "creates a new cache/redis entry" do
        expect { described_class.dates }.to change { BankHolidayStore.read(fallback_to_api_for_cache_miss: false) }
          .from([])
          .to(api_dates)
      end

      it "returns API dates" do
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
