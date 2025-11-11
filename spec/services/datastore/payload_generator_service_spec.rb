require "rails_helper"

RSpec.describe Datastore::PayloadGeneratorService do
  # NOTE: This is an impossible application that should contain every relation it is
  # possible to contain so we can exercise the json builders fully.
  let(:legal_aid_application) do
    create(
      :legal_aid_application,
      :with_proceedings,
      :at_assessment_submitted,
      office: build(:office),
    ).tap do |application|
      p = application.proceedings.first

      # has_one
      p.opponents_application = build(:opponents_application)
      p.attempts_to_settle = build(:attempts_to_settles)
      p.specific_issue = build(:specific_issue)
      p.vary_order = build(:vary_order)
      p.chances_of_success = build(:chances_of_success)
      p.prohibited_steps = build(:prohibited_steps)
      p.child_care_assessment = build(:child_care_assessment)

      # has_many
      p.final_hearings << build(:final_hearing)
      p.proceeding_linked_children << build(:proceeding_linked_child, involved_child: create(:involved_child, legal_aid_application: application))
    end
  end

  describe ".call" do
    subject(:call) { described_class.call(legal_aid_application) }

    it "includes the schema version, at the top-level" do
      expect(call).to include(schema_version: "v1")
    end

    it "includes the application reference, at the top-level" do
      expect(call).to include(application_reference: legal_aid_application.application_ref)
    end

    it "includes the applications status, at the top-level" do
      expect(call).to include(status: "submitted")
    end

    it "includes a modified_at timestamp that reflects when the legal aid application was updated, at the top-level" do
      freeze_time do
        expect(call).to include(modified_at: legal_aid_application.updated_at.iso8601)
      end
    end

    it "includes the application content" do
      payload = LegalAidApplicationJsonBuilder.build(legal_aid_application)

      expect(call).to include(application_data: payload.to_json)
    end

    context "when there is one or more nil objects/relations" do
      let(:legal_aid_application) { create(:legal_aid_application) }

      it "generates the payload with nil for non-existent objects" do
        payload = call
        parsed_payload = JSON.parse(payload[:application_data])

        expect(parsed_payload["applicant"]).to be_nil
      end

      it "generates the payload with empty array for collections with no objects" do
        payload = call
        parsed_payload = JSON.parse(payload[:application_data])

        expect(parsed_payload["proceedings"]).to be_empty
      end
    end
  end
end
