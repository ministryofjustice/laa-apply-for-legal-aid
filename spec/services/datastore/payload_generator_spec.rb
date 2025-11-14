require "rails_helper"

RSpec.describe Datastore::PayloadGenerator do
  # NOTE: This is an impossible application that should contain every relation it is
  # possible to contain so we can exercise the json builders fully.
  let(:legal_aid_application) do
    create(
      :legal_aid_application,
      :with_applicant_and_partner,
      :with_proceedings,
      :with_dependant,
      :with_bank_transactions,
      :at_assessment_submitted,
      office: build(:office, :with_valid_schedule),
      benefit_check_result: build(:benefit_check_result, :negative),
      dwp_override: build(:dwp_override, :with_evidence),
      dwp_result_confirmed: true,
    ).tap do |a|
      p = a.proceedings.first

      # HMRC responses, including employments and employment payments for applicant and partner
      create(:hmrc_response, :use_case_one, legal_aid_application: a, owner_id: a.applicant.id, owner_type: a.applicant.class)
      create(:hmrc_response, :use_case_one, legal_aid_application: a, owner_id: a.partner.id, owner_type: a.partner.class)
      create(:employment, :example1_usecase1, legal_aid_application: a, owner_id: a.applicant.id, owner_type: a.applicant.class)
      create(:employment, :example1_usecase1, legal_aid_application: a, owner_id: a.partner.id, owner_type: a.partner.class)
      create(:legal_framework_merits_task_list, :da001, legal_aid_application: a)

      # linked applications
      create(:linked_application, lead_application: create(:legal_aid_application), associated_application: a)

      # means test data
      maintenance_in = create(:transaction_type, :maintenance_in)
      maintenance_out = create(:transaction_type, :maintenance_out)
      a.legal_aid_application_transaction_types << build(:legal_aid_application_transaction_type, transaction_type: maintenance_in)
      a.legal_aid_application_transaction_types << build(:legal_aid_application_transaction_type, transaction_type: maintenance_out)
      a.regular_transactions << build(:regular_transaction, transaction_type: maintenance_in)
      a.regular_transactions << build(:regular_transaction, transaction_type: maintenance_out)
      a.cash_transactions << build(:cash_transaction, :credit_month1, transaction_type: maintenance_in)
      a.cash_transactions << build(:cash_transaction, :credit_month1, transaction_type: maintenance_out)
      a.capital_disregards = [build(:capital_disregard, :mandatory), build(:capital_disregard, :discretionary)]

      # application level merits, has_one
      a.statement_of_case = build(:statement_of_case)
      a.domestic_abuse_summary = build(:domestic_abuse_summary)
      a.parties_mental_capacity = build(:parties_mental_capacity)
      a.latest_incident = build(:incident)
      a.allegation = build(:allegation)
      a.undertaking = build(:undertaking)
      a.urgency = build(:urgency)
      a.appeal = build(:appeal)
      a.matter_opposition = build(:matter_opposition)

      # proceeding level merits, has one
      p.opponents_application = build(:opponents_application)
      p.attempts_to_settle = build(:attempts_to_settles)
      p.specific_issue = build(:specific_issue)
      p.vary_order = build(:vary_order)
      p.chances_of_success = build(:chances_of_success)
      p.prohibited_steps = build(:prohibited_steps)
      p.child_care_assessment = build(:child_care_assessment)

      # proceeding level merits, has many
      p.final_hearings << build(:final_hearing)
      p.proceeding_linked_children << build(:proceeding_linked_child, involved_child: create(:involved_child, legal_aid_application: a))
    end
  end

  describe ".call" do
    subject(:call) { described_class.call(legal_aid_application) }

    it "includes the schema version, at the top-level" do
      expect(call).to include(schemaVersion: 0)
    end

    it "includes the application reference, at the top-level" do
      expect(call).to include(applicationReference: legal_aid_application.application_ref)
    end

    it "includes the applications status, at the top-level" do
      expect(call).to include(status: "SUBMITTED")
    end

    it "includes the application content as json with transformed keys" do
      payload = LegalAidApplicationJsonBuilder.build(legal_aid_application)

      expect(call).to include(applicationContent: Datastore::Transformer.call(payload.as_json).to_json)
    end

    context "when there is one or more nil objects/relations" do
      let(:legal_aid_application) { create(:legal_aid_application) }

      it "generates the payload with nil for non-existent objects" do
        payload = call
        application_content = JSON.parse(payload[:applicationContent])

        expect(application_content["applicant"]).to be_nil
      end

      it "generates the payload with empty array for collections with no objects" do
        payload = call
        application_content = JSON.parse(payload[:applicationContent])

        expect(application_content["proceedings"]).to be_empty
      end
    end
  end
end
