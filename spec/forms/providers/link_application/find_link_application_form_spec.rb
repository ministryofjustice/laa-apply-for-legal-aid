require "rails_helper"

RSpec.describe Providers::LinkApplication::FindLinkApplicationForm, type: :form do
  subject(:instance) { described_class.new(params) }

  let(:params) do
    {
      search_laa_reference:,
      model: linked_application,
    }
  end
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:merits_submitted_at) { Date.yesterday }
  let(:linked_application) { build(:linked_application, associated_application_id: legal_aid_application.id, link_type_code: "FC_LEAD") }

  before do
    create(:legal_aid_application, provider: legal_aid_application.provider, application_ref: "L-123-456", id: "4806a4a9-ce0f-4db1-8fbc-de746f3ff628", merits_submitted_at:)
    create(:legal_aid_application, application_ref: "L-654-321")
  end

  describe "#application_can_be_linked?" do
    subject(:application_can_be_linked) { instance.application_can_be_linked? }

    context "when the application searched for was created by the providers' firm and has been submitted" do
      let(:search_laa_reference) { "L-123-456" }

      it "returns true" do
        expect(application_can_be_linked).to be true
      end
    end

    context "when the application searched for was created by the providers' firm and has not been submitted" do
      let(:search_laa_reference) { "L-123-456" }
      let(:merits_submitted_at) { nil }

      it "returns true" do
        expect(application_can_be_linked).to be :not_submitted_message
      end
    end

    context "when the application searched for was created by a different firm" do
      let(:search_laa_reference) { "L-654-321" }

      it "returns false" do
        expect(application_can_be_linked).to be :missing_message
      end
    end

    context "when the application searched for does not exist" do
      let(:search_laa_reference) { "L-000-000" }

      it "returns :missing_message" do
        expect(application_can_be_linked).to be :missing_message
      end
    end

    context "when the application searched text is invalid" do
      let(:search_laa_reference) { "not a valid reference" }

      it "returns :missing_message" do
        expect(application_can_be_linked).to be :missing_message
      end
    end

    context "when the application searched text is too short" do
      let(:search_laa_reference) { "L-12" }

      it "returns :missing_message" do
        expect(application_can_be_linked).to be :missing_message
      end
    end

    context "when the application searched text is too short once special characters are removed" do
      let(:search_laa_reference) { "L-12!-@L-" }

      it "returns :missing_message" do
        expect(application_can_be_linked).to be :missing_message
      end
    end

    context "when the application searched for has been discarded" do
      before { LegalAidApplication.find_by(application_ref: "L-123-456").discard! }

      let(:search_laa_reference) { "L-123-456" }

      it "returns :voided_or_deleted_message" do
        expect(application_can_be_linked).to be :voided_or_deleted_message
      end
    end

    context "when the application searched for has expired" do
      before { create(:legal_aid_application, provider: legal_aid_application.provider, application_ref: "L-123-458", created_at: Date.new(2023, 1, 10)) }

      let(:search_laa_reference) { "L-123-458" }

      it "returns :voided_or_deleted_message" do
        expect(application_can_be_linked).to be :voided_or_deleted_message
      end
    end

    context "when the application ref searched for has no hyphens" do
      let(:search_laa_reference) { "L123456" }

      it "returns true" do
        expect(application_can_be_linked).to be true
      end
    end

    context "when the application ref searched for is lower case" do
      let(:search_laa_reference) { "l-123-456" }

      it "returns true" do
        expect(application_can_be_linked).to be true
      end
    end

    context "when the application ref searched for contains special characters or spaces" do
      let(:search_laa_reference) { "!@L-£$%123-^&*456() " }

      it "returns true" do
        expect(application_can_be_linked).to be true
      end
    end
  end

  describe "validation" do
    subject(:valid) { instance.valid? }

    context "when the search_laa_reference is completed" do
      let(:search_laa_reference) { "L-123-456" }

      it "returns true" do
        expect(valid).to be true
      end
    end

    context "when the search_laa_reference is not completed" do
      let(:search_laa_reference) { "" }

      it "returns false" do
        expect(valid).to be false
      end
    end
  end

  describe "#save" do
    subject(:call_save) { instance.save }

    context "when a search reference that exists and is submitted is entered" do
      context "when the search target is not an associated action" do
        before do
          instance.application_can_be_linked?
          call_save
        end

        let(:search_laa_reference) { "L-123-456" }

        it "updates the correct models" do
          expect(linked_application.target_application_id).to eql "4806a4a9-ce0f-4db1-8fbc-de746f3ff628"
          expect(linked_application.lead_application_id).to eql "4806a4a9-ce0f-4db1-8fbc-de746f3ff628"
        end
      end

      context "when the search target is already an associated action" do
        let(:lead_application) { create(:legal_aid_application, provider: legal_aid_application.provider, application_ref: "L-111-222", id: "f1b3c2ef-1e93-4d4e-a983-643598f1eaf4", merits_submitted_at:) }
        let(:search_target) { create(:legal_aid_application, provider: legal_aid_application.provider, application_ref: "L-333-444", id: "42edab70-1584-4fc6-9a42-7e3eae3ca726", merits_submitted_at:) }
        let(:search_laa_reference) { "L-333-444" }

        before do
          create(:linked_application, lead_application:, associated_application: search_target, link_type_code: "FC_LEAD")
          instance.application_can_be_linked?
          call_save
        end

        it "sets the target_application as the search result and the lead_application as it's lead application" do
          expect(linked_application.target_application_id).to eql "42edab70-1584-4fc6-9a42-7e3eae3ca726"
          expect(linked_application.lead_application_id).to eql "f1b3c2ef-1e93-4d4e-a983-643598f1eaf4"
        end
      end
    end
  end
end
