require "rails_helper"

RSpec.describe LinkedApplicationsHelper do
  describe "#all_linked_applications_details" do
    subject(:details) { all_linked_applications_details(legal_aid_application) }

    let(:legal_aid_application) { create(:legal_aid_application) }
    let(:lead_application) { create(:legal_aid_application) }
    let(:linked_application_one) { create(:legal_aid_application, application_ref: "L-INK-001", applicant: applicant_one) }
    let(:linked_application_two) { create(:legal_aid_application, application_ref: "L-INK-002", applicant: applicant_two) }
    let(:linked_application_three) { create(:legal_aid_application, application_ref: "L-INK-003", applicant: applicant_three) }
    let(:linked_application_four) { create(:legal_aid_application, application_ref: "L-INK-004", applicant: applicant_four, discarded_at: Date.current) }
    let(:applicant_one) { create(:applicant, last_name: "applicant-one", first_name: "linked") }
    let(:applicant_two) { create(:applicant, last_name: "applicant-two", first_name: "linked") }
    let(:applicant_three) { create(:applicant, last_name: "applicant-three", first_name: "linked") }
    let(:applicant_four) { create(:applicant, last_name: "applicant-four", first_name: "linked") }

    context "with a lead application linked to other applications" do
      before do
        LinkedApplication.create!(lead_application_id: lead_application.id, target_application_id: lead_application.id, associated_application_id: legal_aid_application.id, link_type_code: "FC_LEAD")
        LinkedApplication.create!(lead_application_id: lead_application.id, target_application_id: lead_application.id, associated_application_id: linked_application_one.id, link_type_code: "FC_LEAD")
        LinkedApplication.create!(lead_application_id: lead_application.id, target_application_id: lead_application.id, associated_application_id: linked_application_two.id, link_type_code: "LEGAL")
        LinkedApplication.create!(lead_application_id: lead_application.id, target_application_id: linked_application_one.id, associated_application_id: linked_application_three.id, link_type_code: "FC_LEAD")
        LinkedApplication.create!(lead_application_id: lead_application.id, target_application_id: lead_application.id, associated_application_id: linked_application_four.id, link_type_code: "FC_LEAD")
      end

      it "returns details of all other applications linked to the lead application with the same link type that have not been discarded" do
        expect(details).to eq "L-INK-001, linked applicant-one<br>L-INK-003, linked applicant-three"
      end
    end

    context "with a lead application that is not linked to any other applications" do
      before do
        LinkedApplication.create!(lead_application_id: lead_application.id, target_application_id: lead_application.id, associated_application_id: legal_aid_application.id, link_type_code: "FC_LEAD")
      end

      it "returns an empty string" do
        expect(details).to eq ""
      end
    end

    context "with no lead application" do
      before do
        LinkedApplication.create!(associated_application_id: legal_aid_application.id, link_type_code: "FC_LEAD")
      end

      it "returns nil" do
        expect(details).to be_nil
      end
    end
  end
end
