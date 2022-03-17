require "rails_helper"

RSpec.describe MarkPurgeableService do
  describe ".call" do
    let(:old_date1) { 24.months.ago }
    let(:old_date2) { 23.months.ago - 1.day }
    let!(:old1) { create :legal_aid_application, updated_at: old_date1 }
    let!(:old2) { create :legal_aid_application, updated_at: old_date2 }
    let!(:new1) { create :legal_aid_application, updated_at: 23.months.ago + 1.day }
    let!(:new2) { create :legal_aid_application, updated_at: 6.months.ago }

    it "marks all records not updated for 23 months as purgeable" do
      described_class.call
      expect(old1.reload.purgeable_on).to eq (old_date1 + 730.days).to_date
      expect(old2.reload.purgeable_on).to eq (old_date2 + 730.days).to_date
      expect(new1.reload.purgeable_on).to be_nil
      expect(new2.reload.purgeable_on).to be_nil
    end
  end
end
