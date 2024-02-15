require "rails_helper"

RSpec.describe Setting do
  describe ".setting" do
    context "when there is no setting record" do
      before { described_class.delete_all }

      it "generates one with the default values" do
        rec = described_class.setting
        expect(rec.mock_true_layer_data?).to be false
        expect(rec.manually_review_all_cases?).to be true
        expect(rec.allow_welsh_translation?).to be false
        expect(rec.bank_transaction_filename).to eq "db/sample_data/bank_transactions.csv"
        expect(rec.alert_via_sentry?).to be true
        expect(rec.partner_means_assessment?).to be false
        expect(rec.linked_applications?).to be false
        expect(rec.collect_hmrc_data?).to be false
        expect(rec.home_address?).to be false
      end
    end

    context "when a record already exists with non-default values" do
      before do
        described_class.setting.update!(
          mock_true_layer_data: true,
          manually_review_all_cases: false,
          allow_welsh_translation: false,
          enable_ccms_submission: false,
          bank_transaction_filename: "my_special_file.csv",
          alert_via_sentry: true,
          partner_means_assessment: true,
          linked_applications: true,
          collect_hmrc_data: true,
          home_address: false,
        )
      end

      it "returns the existing record" do
        rec = described_class.setting
        expect(rec.mock_true_layer_data?).to be true
        expect(rec.manually_review_all_cases?).to be false
        expect(rec.allow_welsh_translation?).to be false
        expect(rec.enable_ccms_submission?).to be false
        expect(rec.bank_transaction_filename).to eq "my_special_file.csv"
        expect(rec.alert_via_sentry?).to be true
        expect(rec.partner_means_assessment?).to be true
        expect(rec.linked_applications?).to be true
        expect(rec.collect_hmrc_data?).to be true
        expect(rec.home_address?).to be false
      end
    end
  end

  describe "class methods" do
    before { described_class.destroy_all }

    it "returns the value with a class method" do
      expect(described_class.mock_true_layer_data?).to be false
      expect(described_class.manually_review_all_cases?).to be true
      expect(described_class.allow_welsh_translation?).to be false
      expect(described_class.enable_ccms_submission?).to be true
      expect(described_class.bank_transaction_filename).to eq "db/sample_data/bank_transactions.csv"
      expect(described_class.alert_via_sentry?).to be true
      expect(described_class.partner_means_assessment?).to be false
      expect(described_class.linked_applications?).to be false
      expect(described_class.collect_hmrc_data?).to be false
      expect(described_class.home_address?).to be false
    end
  end
end
