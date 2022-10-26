require "rails_helper"

RSpec.describe DigestExtractor do
  describe ".call" do
    let!(:laa1) { create(:legal_aid_application, :with_applicant, :with_cfe_v3_result, updated_at: 5.days.ago) }
    let!(:laa2) { create(:legal_aid_application, :with_applicant, :with_cfe_v3_result, updated_at: 3.days.ago) }
    let!(:laa3) { create(:legal_aid_application, :with_applicant, :with_cfe_v3_result, updated_at: 1.minute.ago) }

    before { Setting.setting.update!(digest_extracted_at: 4.days.ago) }

    it "calls ApplicationDigest for each record updated since last extraction date" do
      expect(ApplicationDigest).to receive(:create_or_update!).with(laa2.id)
      expect(ApplicationDigest).to receive(:create_or_update!).with(laa3.id)
      expect(ApplicationDigest).not_to receive(:create_or_update!).with(laa1.id)

      described_class.call
    end

    it "updates the settings table with current time" do
      freeze_time do
        described_class.call
      end
      expect(Setting.setting.digest_extracted_at >= 2.seconds.ago).to be true
    end
  end
end
