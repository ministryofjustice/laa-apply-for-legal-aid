RSpec.shared_examples "an overrides_form" do
  describe "validation" do
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

    context "when saving as draft" do
      before { form.save_as_draft }

      it { is_expected.to be_valid }
    end
  end
end
