require "rails_helper"

RSpec.describe DigestExtractor do
  describe ".call" do
    let!(:application_five_day_old) { create(:legal_aid_application, :with_applicant, :with_cfe_v3_result, updated_at: 5.days.ago) }
    let!(:application_three_day_old) { create(:legal_aid_application, :with_applicant, :with_cfe_v3_result, updated_at: 3.days.ago) }
    let!(:application_one_minute_old) { create(:legal_aid_application, :with_applicant, :with_cfe_v3_result, updated_at: 1.minute.ago) }

    before { Setting.setting.update!(digest_extracted_at: 4.days.ago) }

    it "calls ApplicationDigest for each record updated since last extraction date" do
      expect(ApplicationDigest).to receive(:create_or_update!).with(application_three_day_old.id)
      expect(ApplicationDigest).to receive(:create_or_update!).with(application_one_minute_old.id)
      expect(ApplicationDigest).not_to receive(:create_or_update!).with(application_five_day_old.id)

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
