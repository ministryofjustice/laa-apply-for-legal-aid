require "rails_helper"

RSpec.describe Providers::DWP::OverridesForm, type: :form do
  subject(:form) { described_class.new(params) }

  let(:params) { { confirm_dwp_result: nil } }

  describe "validation" do
    before { form.valid? }

    context "when the dwp result is correct" do
      let(:params) { { confirm_dwp_result: "no_benefit_received" } }

      it { is_expected.to be_valid }
    end

    context "when the applicant receives a passporting benefit that is not joint" do
      let(:params) { { confirm_dwp_result: "benefit_received" } }

      it { is_expected.to be_valid }
    end

    context "when the applicant receives a joint passporting benefit with their partner" do
      let(:params) { { confirm_dwp_result: "joint_benefit_with_partner" } }

      it { is_expected.to be_valid }
    end

    context "when the parameters are missing" do
      it { is_expected.not_to be_valid }

      it "records the error message" do
        expect(form.errors[:confirm_dwp_result]).to eq [I18n.t("providers.confirm_dwp_non_passported_applications.show.error")]
      end
    end

    context "when saving as draft" do
      before { form.save_as_draft }

      it { is_expected.to be_valid }
    end
  end
end
