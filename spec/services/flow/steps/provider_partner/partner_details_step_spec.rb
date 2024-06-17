require "rails_helper"

RSpec.describe Flow::Steps::ProviderPartner::PartnerDetailsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_partners_details_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when overriding dwp result" do
      let(:legal_aid_application) { create(:legal_aid_application, :overriding_dwp_result) }

      it { is_expected.to be :check_client_details }
    end

    context "when not overriding dwp result" do
      it { is_expected.to be :check_provider_answers }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to be :check_provider_answers }
  end

  describe "#carry_on_sub_flow" do
    subject { described_class.carry_on_sub_flow }

    it { is_expected.to be false }
  end
end
