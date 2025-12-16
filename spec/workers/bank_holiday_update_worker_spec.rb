require "rails_helper"

RSpec.describe BankHolidayUpdateWorker, vcr: { cassette_name: "gov_uk_bank_holiday_api", allow_playback_repeats: true } do
  subject(:update_worker) { bank_holiday_update_worker.perform }

  let(:bank_holiday_update_worker) { described_class.new }
  let(:stale_date) { Time.current.utc - 1.month - 2.hours }

  describe "#perform" do
    context "when there is no existing bank holiday data" do
      before { BankHoliday.delete_all }

      it "creates a new bank holiday instance" do
        expect { update_worker }.to change(BankHoliday, :count).by(1)
      end
    end

    context "when current data is not stale" do
      before { create(:bank_holiday) }

      it "returns true" do
        expect(update_worker).to be true
      end

      it "does not change the bank holiday" do
        expect { update_worker }.not_to change(BankHoliday.first, :reload)
      end

      it "does not create a new bank holiday" do
        expect { update_worker }.not_to change(BankHoliday, :count)
      end
    end

    context "when outdated data is different from latest data from API" do
      before { create(:bank_holiday, updated_at: stale_date) }

      it "creates a new bank holiday instance" do
        expect { update_worker }.to change(BankHoliday, :count).by(1)
      end
    end

    context "when outdated data is the same as latest data from API" do
      let!(:bank_holiday) { BankHoliday.create(updated_at: stale_date) }

      it "does not create a new bank holiday" do
        expect { update_worker }.not_to change(BankHoliday, :count)
      end

      it "does not change the dates of the bank holiday record" do
        expect { update_worker }.not_to change(BankHoliday.by_updated_at.last, :dates)
      end

      it "touches the existing bank holidays record" do
        update_worker
        expect(bank_holiday.reload.updated_at).to be_between(2.seconds.ago, 1.second.from_now)
      end
    end

    context "when data retrieval fails" do
      before { create(:bank_holiday, updated_at: stale_date) }

      it "raises error" do
        allow(BankHolidayRetriever).to receive(:dates).and_raise(BankHolidayRetriever::UnsuccessfulRetrievalError)
        expect { update_worker }.to raise_error(BankHolidayRetriever::UnsuccessfulRetrievalError)
      end
    end
  end
end
