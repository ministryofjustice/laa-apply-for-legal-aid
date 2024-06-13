require "rails_helper"

RSpec.describe Flow::Steps::ProceedingsSCA::HeardTogethersStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_heard_togethers_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, heard_together) }

    context "when proceedings are heard together" do
      let(:heard_together) { true }

      it { is_expected.to be :has_other_proceedings }
    end

    context "when proceedings are not heard together" do
      let(:heard_together) { false }

      it { is_expected.to be :proceedings_sca_heard_as_alternatives }
    end
  end
end
