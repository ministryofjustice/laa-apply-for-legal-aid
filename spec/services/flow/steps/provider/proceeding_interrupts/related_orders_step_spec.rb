require "rails_helper"

RSpec.describe Flow::Steps::Provider::ProceedingInterrupts::RelatedOrdersStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application, proceeding) }

    let(:proceeding) { build_stubbed(:proceeding, ccms_code: "PBM016E") }

    it { is_expected.to eq providers_legal_aid_application_related_order_path(legal_aid_application, proceeding) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, proceeding) }

    context "when proceeding should redirect" do
      let(:proceeding) { build_stubbed(:proceeding, ccms_code: "PBM16E") }

      it { is_expected.to be :change_of_names }
    end

    context "when proceeding should not redirect" do
      let(:proceeding) { build_stubbed(:proceeding, ccms_code: "PBM03") }

      it { is_expected.to be :has_other_proceedings }
    end
  end
end
