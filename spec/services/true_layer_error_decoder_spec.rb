require "rails_helper"

RSpec.describe TrueLayerErrorDecoder do
  subject(:true_layer_error_decoder) { described_class.new(error_details) }

  let(:error_details) { true_layer_error_details_array }
  let(:error_description) { "TrueLayer's detailed explanation of the error" }

  describe "#error_heading" do
    context "when a known error occurs" do
      let(:error_code) { "account_temporarily_locked" }

      it "returns the correct translation" do
        expect(true_layer_error_decoder.error_heading).to eq I18n.t("true_layer_errors.headings.account_temporarily_locked")
      end
    end

    context "when an unknown error occurs" do
      let(:error_code) { "flux_capacitor_outage" }
      let(:error_description) { "The flux capacitor is not working" }

      it "returns the generic unknown error message" do
        expect(true_layer_error_decoder.error_heading).to eq I18n.t("true_layer_errors.headings.unknown")
      end

      it "sends the details to sentry" do
        expect(AlertManager).to receive(:capture_message).with("Unknown error code received from TrueLayer: flux_capacitor_outage :: The flux capacitor is not working")
        true_layer_error_decoder.error_heading
      end
    end
  end

  describe "#error_details" do
    context "when a known error occurs" do
      let(:error_code) { "internal_server_error" }

      it "returns the correct translation" do
        expect(true_layer_error_decoder.error_detail).to eq I18n.t("true_layer_errors.detail.internal_server_error")
      end
    end

    context "when an unknown error occurs" do
      let(:error_code) { "flux_capacitor_outage" }
      let(:error_description) { "The flux capacitor is not working" }

      it "returns the generic unknown error message" do
        expect(true_layer_error_decoder.error_detail).to eq I18n.t("true_layer_errors.detail.unknown")
      end
    end
  end

  describe "#show_link?" do
    context "when the link is shown" do
      let(:error_code) { "wrong_credentials" }

      it "returns true" do
        expect(true_layer_error_decoder.show_link?).to be true
      end
    end

    context "when no link is shown" do
      let(:error_code) { "account_permanently_locked" }

      it "returns true" do
        expect(true_layer_error_decoder.show_link?).to be false
      end
    end
  end

  def true_layer_error_details_array
    [
      "bank_data_import",
      "import_account_holders",
      true_layer_error_hash.to_json,
    ]
  end

  def true_layer_error_hash
    {
      "TrueLayerError" => {
        "error_description" => error_description,
        "error" => error_code,
        "error_details" => {},
      },
    }
  end
end
