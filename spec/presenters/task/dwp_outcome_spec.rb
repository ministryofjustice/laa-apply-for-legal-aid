require "rails_helper"

RSpec.describe Task::DWPOutcome do
  subject(:instance) { described_class.new(application, name: "dwp_outcome", status_results: {}) }

  let(:application) { create(:legal_aid_application, :with_applicant) }

  describe "#path" do
    include Rails.application.routes.url_helpers

    it "returns the route to first step of the task list item" do
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
  end
end
