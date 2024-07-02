require "rails_helper"

RSpec.describe Flow::Steps::ProceedingsSCA::HeardAsAlternativesStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  describe "#path" do
    subject(:path) { described_class.path.call(legal_aid_application, parameters) }

    context "when the proceeding is passed direct" do
      let(:parameters) { { proceeding: } }
      let(:proceeding) { build_stubbed(:proceeding, ccms_code: "PB020") }

      it { is_expected.to eql providers_legal_aid_application_heard_as_alternative_path(legal_aid_application, proceeding) }
    end

    context "when the proceeding is passed as part of an options hash" do
      let(:parameters) { { heard_together: false, proceeding: } }
      let(:proceeding) { build_stubbed(:proceeding, ccms_code: "PB020") }

      it { is_expected.to eql providers_legal_aid_application_heard_as_alternative_path(legal_aid_application, proceeding) }
    end
  end

  describe "#forward" do
    subject(:path) { described_class.forward.call(legal_aid_application, proceeding) }

    context "and the proceeding is a Prohibited steps order" do
      let(:proceeding) { build_stubbed(:proceeding, ccms_code: "PB019") }

      it { is_expected.to be :proceedings_sca_change_of_names }
    end

    context "and the proceeding is a Specific issue order vary order" do
      let(:proceeding) { build_stubbed(:proceeding, ccms_code: "PB024") }

      it { is_expected.to be :proceedings_sca_change_of_names }
    end

    context "and the proceeding is neither SIO or PIO" do
      let(:proceeding) { build_stubbed(:proceeding, :pb007) }

      it { is_expected.to be :has_other_proceedings }
    end
  end
end
