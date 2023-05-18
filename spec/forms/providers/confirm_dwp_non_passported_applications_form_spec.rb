require "rails_helper"

RSpec.describe Providers::ConfirmDWPNonPassportedApplicationsForm, type: :form do
  subject(:form) { described_class.new(params) }

  let(:params) { { confirm_dwp_result: nil } }

  describe "#save" do
    context "with validation" do
      before { form.valid? }

      context "when the dwp result is correct" do
        let(:params) { { confirm_dwp_result: "dwp_correct" } }

        it { is_expected.to be_valid }
      end

      context "when the applicant receives a passporting benefit that is not joint" do
        let(:params) { { confirm_dwp_result: "joint_with_partner_false" } }

        it { is_expected.to be_valid }
      end

      context "when the applicant receives a joint passporting benefit with their partner" do
        let(:params) { { confirm_dwp_result: "joint_with_partner_true" } }

        it { is_expected.to be_valid }
      end

      context "when the parameters are missing" do
        it { is_expected.to be_invalid }

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

  # describe "#initialize" do
  #   context "the provider has previously selected that the client gets a joint passporting benefit" do
  #     let(:application) { create(:legal_aid_application, :with_partner_and_joint_benefit) }
  #     # let(:partner) { application.partner }
  #     let(:partner) { create(:partner, shared_benefit_with_applicant: true) }

  #     let(:params) {  partner }

  #     it 'sets confirm_dwp_result to joint_with_partner_true' do

  #       # expect(form.attributes["confirm_dwp_result"]).to eq "joint_with_partner_true"
  #       binding.pry
  #       expect(form).to have_attributes()
  #     end
  #   end
  # end
end
