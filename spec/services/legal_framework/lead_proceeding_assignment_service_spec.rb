require "rails_helper"

module LegalFramework
  RSpec.describe LeadProceedingAssignmentService do
    subject(:lead_proceeding_assignment) { described_class.call(laa) }

    let(:p_da1) { laa.proceedings.where(ccms_code: "DA001").first }
    let(:p_da2) { laa.proceedings.where(ccms_code: "DA004").first }
    let(:p_s81) { laa.proceedings.where(ccms_code: "SE013").first }
    let(:p_s82) { laa.proceedings.where(ccms_code: "SE014").first }
    let(:laa) { create(:legal_aid_application, :with_proceedings, explicit_proceedings:, set_lead_proceeding: false) }

    context "when a lead proceeding already exists" do
      let(:explicit_proceedings) { %i[da001 da004 se013 se014] }

      before { make_lead!(p_da2) }

      it "changes nothing" do
        lead_proceeding_assignment
        expect(p_s81.lead_proceeding?).to be false
        expect(p_s82.lead_proceeding?).to be false
        expect(p_da1.lead_proceeding?).to be false
        expect(p_da2.lead_proceeding?).to be true
      end
    end

    context "when there are no lead proceedings" do
      let(:explicit_proceedings) { %i[se013 se014 da001] }
      let(:first_proceeding) { laa.proceedings.in_order_of_addition.first }

      it "sets the proceeding added first as the lead proceeding" do
        lead_proceeding_assignment
        expect(first_proceeding.lead_proceeding?).to be true
        laa.proceedings.in_order_of_addition[1..].each do |proceeding|
          expect(proceeding.lead_proceeding?).to be false
        end
      end
    end

    context "when there are no domestic abuse proceedings" do
      let(:explicit_proceedings) { %i[se013 se014] }

      it "sets the proceeding added first as the lead proceeding" do
        lead_proceeding_assignment
        expect(p_s81.lead_proceeding?).to be true
        expect(p_s82.lead_proceeding?).to be false
      end
    end

    def make_lead!(proceeding)
      proceeding.update!(lead_proceeding: true)
    end
  end
end
