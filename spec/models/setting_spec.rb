require "rails_helper"

RSpec.describe Setting do
  describe ".setting" do
    subject(:setting) { described_class.setting }

    context "when there is a setting record" do
      let!(:existing_setting) { described_class.create! }

      it "returns the existing record" do
        expect(setting).to eq(existing_setting)
      end
    end

    context "when there is no setting record" do
      it "creates one" do
        expect { setting }.to change(described_class, :count).from(0).to(1)
      end

      it "returns a Setting with default values" do
        expect(setting).to have_attributes(
          mock_true_layer_data: false,
          manually_review_all_cases: true,
          allow_welsh_translation: false,
          bank_transaction_filename: "db/sample_data/bank_transactions.csv",
          alert_via_sentry: true,
          partner_means_assessment: false,
        )
      end
    end
  end

  describe ".method_missing" do
    context "when the method exists on the setting" do
      it "returns the value" do
        expect(described_class.partner_means_assessment?).to be(false)
      end
    end

    context "when the method does not exist on the setting" do
      it "raises an error" do
        expect { described_class.not_a_setting }.to raise_error(NoMethodError)
      end
    end
  end

  describe ".bank_transaction_filename" do
    subject(:bank_transaction_filename) do
      described_class.bank_transaction_filename
    end

    before { described_class.create!(bank_transaction_filename: "test.csv") }

    it "returns the value" do
      expect(bank_transaction_filename).to eq("test.csv")
    end
  end
end
