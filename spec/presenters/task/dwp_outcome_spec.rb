require "rails_helper"

RSpec.describe Task::DWPOutcome do
  subject(:instance) { described_class.new(application, name: "dwp_outcome") }

  let(:application) { create(:legal_aid_application, :with_applicant, dwp_result_confirmed:, dwp_override:) }
  let(:dwp_result_confirmed) { nil }
  let(:dwp_override) { nil }

  describe "#path" do
    include Rails.application.routes.url_helpers

    it "returns the correct step" do
      expect(instance.path).to eql providers_legal_aid_application_dwp_result_path(application)
    end

    context "when no national insurance number has been entered for the applicant" do
      before { application.applicant.update!(national_insurance_number: nil) }

      it "returns the correct step" do
        expect(instance.path).to eql providers_legal_aid_application_no_national_insurance_number_path(application)
      end
    end

    context "when the applicant is under 18" do
      before { application.applicant.update!(age_for_means_test_purposes: 17) }

      it "returns the correct step" do
        expect(instance.path).to eql providers_legal_aid_application_confirm_non_means_tested_applications_path(application)
      end
    end

    context "when the provider is checking client details" do
      let(:dwp_result_confirmed) { false }

      it "returns the correct step" do
        expect(instance.path).to eql providers_legal_aid_application_check_client_details_path(application)
      end

      context "when the applicant has a partner" do
        let(:partner) { create(:partner) }

        before { application.update!(partner:) }

        it "returns the correct step" do
          expect(instance.path).to eql providers_legal_aid_application_dwp_partner_override_path(application)
        end
      end
    end

    context "when the provider is overriding the dwp result" do
      let(:dwp_result_confirmed) { false }

      context "when the provider is selecting which passporting benefit the applicant receives" do
        let(:dwp_override) { create(:dwp_override, passporting_benefit: nil) }

        it "returns the correct step" do
          expect(instance.path).to eql providers_legal_aid_application_received_benefit_confirmation_path(application)
        end
      end

      context "when the provider is entering whether they have evidence of benefits" do
        let(:dwp_override) { create(:dwp_override, passporting_benefit: "Universal Credit") }

        it "returns the correct step" do
          expect(instance.path).to eql providers_legal_aid_application_has_evidence_of_benefit_path(application)
        end
      end
    end
  end
end
