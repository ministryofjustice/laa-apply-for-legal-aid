require "rails_helper"

RSpec.describe DestroyPurgeableService do
  let!(:nil_rec) { create :legal_aid_application, purgeable_on: nil, updated_at: 731.days.ago }
  let!(:tomorrow_rec) { create :legal_aid_application, purgeable_on: Time.zone.tomorrow, updated_at: 731.days.ago }
  let!(:yesterday_rec) { create :legal_aid_application, purgeable_on: Time.zone.yesterday, updated_at: 731.days.ago }
  let!(:today_rec) { create :legal_aid_application, purgeable_on: Time.zone.today, updated_at: 731.days.ago }
  let!(:recently_updated_rec) { create :legal_aid_application, purgeable_on: Time.zone.yesterday, updated_at: 729.days.ago }

  before { described_class.call }

  describe ".call" do
    it "does not delete records with null purgeable_on" do
      expect(LegalAidApplication.find(nil_rec.id)).to be_present
    end

    it "does not delete records with purgeable_on in the future" do
      expect(LegalAidApplication.find(tomorrow_rec.id)).to be_present
    end

    it "deletes records with purgeable_on in the past" do
      expect { LegalAidApplication.find(yesterday_rec.id) }.to raise_error ActiveRecord::RecordNotFound
    end

    it "deletes records with purgeable_on today" do
      expect { LegalAidApplication.find(today_rec.id) }.to raise_error ActiveRecord::RecordNotFound
    end

    it "does not delete records with past purgeable on dates but updated at less 730 days ago" do
      expect(LegalAidApplication.find(recently_updated_rec.id)).to be_present
    end
  end
end
