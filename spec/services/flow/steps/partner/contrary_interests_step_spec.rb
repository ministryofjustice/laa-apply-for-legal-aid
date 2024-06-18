require "rails_helper"

RSpec.describe Flow::Steps::Partner::ContraryInterestsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_contrary_interest_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, options) }

    context "when provider has partner with contrary interest" do
      let(:options) { { partner_has_contrary_interest: true } }

      it { is_expected.to be :check_provider_answers }
    end

    context "when provider has partner with no contrary interest" do
      let(:options) { { partner_has_contrary_interest: false } }

      it { is_expected.to be :partner_details }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application, options) }

    context "when provider has partner with contrary interest" do
      let(:options) { { partner_has_contrary_interest: true } }

      it { is_expected.to be :check_provider_answers }
    end

    context "when provider has partner with no contrary interest" do
      let(:options) { { partner_has_contrary_interest: false } }

      it { is_expected.to be :partner_details }
    end
  end
end
