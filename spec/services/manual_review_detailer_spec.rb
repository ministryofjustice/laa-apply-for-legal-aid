require "rails_helper"

RSpec.describe ManualReviewDetailer do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:applicant) { legal_aid_application.applicant }

  describe ".call" do
    context "when there are no restrictions, no policy disregards. no extra employment information" do
      before do
        allow(legal_aid_application).to receive_messages(has_restrictions?: false, policy_disregards?: false)
        allow(applicant).to receive(:extra_employment_information?).and_return(false)
      end

      it "returns an empty array" do
        expect(described_class.call(legal_aid_application)).to eq []
      end

      context "when there are no restrictions, no policy disregards, with full employment details manually entered by the provider" do
        before do
          allow(legal_aid_application).to receive_messages(has_restrictions?: false, policy_disregards?: false, full_employment_details: "test details")
        end

        it "returns an array with one entry" do
          expect(described_class.call(legal_aid_application)).to eq [I18n.t("shared.assessment_results.manual_check_required.extra_employment_information")]
        end
      end
    end

    context "when there are restrictions, no policy disregards, with extra employment information" do
      before do
        allow(legal_aid_application).to receive_messages(has_restrictions?: true, policy_disregards?: false)
        allow(applicant).to receive(:extra_employment_information?).and_return(true)
      end

      it "returns an array with two entries" do
        expect(described_class.call(legal_aid_application)).to eq [I18n.t("shared.assessment_results.manual_check_required.restrictions"),
                                                                   I18n.t("shared.assessment_results.manual_check_required.extra_employment_information")]
      end
    end

    context "when there are restrictions, with policy disregards and with extra employment information" do
      before do
        allow(legal_aid_application).to receive_messages(has_restrictions?: true, policy_disregards?: true)
        allow(applicant).to receive(:extra_employment_information?).and_return(true)
      end

      it "returns an array with three entries" do
        expect(described_class.call(legal_aid_application)).to eq [I18n.t("shared.assessment_results.manual_check_required.restrictions"),
                                                                   I18n.t("shared.assessment_results.manual_check_required.policy_disregards"),
                                                                   I18n.t("shared.assessment_results.manual_check_required.extra_employment_information")]
      end
    end

    context "when there are restrictions, without policy disregards, with capital disregards and with extra employment information" do
      before do
        allow(legal_aid_application).to receive_messages(has_restrictions?: true, policy_disregards?: false, capital_disregards?: true)
        allow(applicant).to receive(:extra_employment_information?).and_return(true)
      end

      it "returns an array with three entries" do
        expect(described_class.call(legal_aid_application)).to eq [I18n.t("shared.assessment_results.manual_check_required.restrictions"),
                                                                   I18n.t("shared.assessment_results.manual_check_required.policy_disregards"),
                                                                   I18n.t("shared.assessment_results.manual_check_required.extra_employment_information")]
      end
    end

    context "when there are restrictions, with policy disregards and with full employment details manually entered by the provider" do
      before do
        allow(legal_aid_application).to receive_messages(has_restrictions?: true, policy_disregards?: true, full_employment_details: "test details")
      end

      it "returns an array with three entries" do
        expect(described_class.call(legal_aid_application)).to eq [I18n.t("shared.assessment_results.manual_check_required.restrictions"),
                                                                   I18n.t("shared.assessment_results.manual_check_required.policy_disregards"),
                                                                   I18n.t("shared.assessment_results.manual_check_required.extra_employment_information")]
      end
    end
  end
end
