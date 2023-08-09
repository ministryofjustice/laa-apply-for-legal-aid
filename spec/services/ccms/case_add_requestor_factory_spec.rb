require "rails_helper"

module CCMS
  RSpec.describe CaseAddRequestorFactory, :ccms do
    let(:submission) { create(:submission, legal_aid_application:) }

    context "with passported application" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_positive_benefit_check_result) }

      it "returns an instance of CaseAddRequestor" do
        expect(described_class.call(submission, {})).to be_instance_of(Requestors::CaseAddRequestor)
      end
    end

    context "with non-passported application" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_negative_benefit_check_result) }

      it "returns an instance of NonPassportedCaseAddRequestor" do
        expect(described_class.call(submission, {})).to be_instance_of(Requestors::NonPassportedCaseAddRequestor)
      end
    end

    context "with non-means-tested application" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_under_18_applicant) }

      it "returns an instance of NonMeansTestedCaseAddRequestor" do
        expect(described_class.call(submission, {})).to be_instance_of(Requestors::NonMeansTestedCaseAddRequestor)
      end
    end
  end
end
