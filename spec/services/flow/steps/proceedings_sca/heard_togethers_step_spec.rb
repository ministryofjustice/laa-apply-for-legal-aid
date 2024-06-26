require "rails_helper"

RSpec.describe Flow::Steps::ProceedingsSCA::HeardTogethersStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application, proceeding) }

    let(:proceeding) { build_stubbed(:proceeding, ccms_code: "PB020") }

    it { is_expected.to eql providers_legal_aid_application_heard_together_path(legal_aid_application, proceeding) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, options) }

    let(:options) { { heard_together:, proceeding: } }

    context "when proceedings are heard together" do
      let(:heard_together) { true }

      context "and the proceeding is a Prohibited steps order" do
        let(:proceeding) { build_stubbed(:proceeding, ccms_code: "PB023") }

        it { is_expected.to be :proceedings_sca_change_of_names }
      end

      context "and the proceeding is a Specific issue order" do
        let(:proceeding) { build_stubbed(:proceeding, ccms_code: "PB024") }

        it { is_expected.to be :proceedings_sca_change_of_names }
      end

      context "and the proceeding is neither SIO or PIO" do
        let(:proceeding) { build_stubbed(:proceeding, :pb007) }

        it { is_expected.to be :has_other_proceedings }
      end
    end

    context "when proceedings are not heard together" do
      let(:heard_together) { false }
      let(:proceeding) { build_stubbed(:proceeding, ccms_code: "PB023") }

      it { is_expected.to be :proceedings_sca_heard_as_alternatives }
    end
  end
end
