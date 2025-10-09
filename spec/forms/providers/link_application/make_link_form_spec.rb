require "rails_helper"

RSpec.describe Providers::LinkApplication::MakeLinkForm, type: :form do
  subject(:instance) { described_class.new(params) }

  let(:params) do
    {
      link_type_code:,
      model: linked_application,
    }
  end
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:linked_application) { build(:linked_application, associated_application_id: legal_aid_application.id) }

  describe "#save" do
    subject(:call_save) { instance.save }

    context "with family link type chosen" do
      let(:link_type_code) { "FC_LEAD" }

      it "sets the link_type_code" do
        call_save
        expect(legal_aid_application.lead_linked_application).to have_attributes(link_type_code: "FC_LEAD",
                                                                                 confirm_link: nil)
      end

      it "sets linked_application_completed to false" do
        expect { call_save }.to change { legal_aid_application.reload.linked_application_completed }.from(nil).to(false)
      end
    end

    context "with legal link type chosen" do
      before { call_save }

      let(:link_type_code) { "LEGAL" }

      it "sets the link_type_code" do
        expect(legal_aid_application.lead_linked_application).to have_attributes(link_type_code: "LEGAL",
                                                                                 confirm_link: nil)
      end

      it "does not copy the application" do
        expect(legal_aid_application.copy_case).to be_nil
        expect(legal_aid_application.copy_case_id).to be_nil
      end

      it "sets linked_application_completed to false" do
        expect(legal_aid_application.reload.linked_application_completed).to be false
      end
    end

    context "with link type no chosen" do
      let(:link_type_code) { "false" }

      it "sets the link_type_code" do
        call_save
        expect(legal_aid_application.lead_linked_application).to have_attributes(link_type_code: "false",
                                                                                 confirm_link: false)
      end

      it "sets linked_application_completed to true" do
        expect { call_save }.to change { legal_aid_application.reload.linked_application_completed }.from(nil).to(true)
      end
    end

    context "with link type nil" do
      before { call_save }

      let(:link_type_code) { nil }

      it "is invalid" do
        expect(instance).not_to be_valid
      end

      it "adds custom blank error message" do
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Select if you want to link this application with another one")
      end
    end

    context "when the answer is changed from yes to no" do
      let(:linked_application) { build(:linked_application, associated_application_id: legal_aid_application.id, link_type_code: "FC_LEAD") }
      let(:link_type_code) { "false" }

      it "resets the linked_application model" do
        call_save
        expect(linked_application.confirm_link).to be false
      end
    end

    context "when the answer is changed from family link to legal link" do
      let(:associated_application) { create(:legal_aid_application, copy_case: true, copy_case_id: legal_aid_application.id) }
      let(:linked_application) { build(:linked_application, associated_application:, lead_application: legal_aid_application, link_type_code: "FC_LEAD") }
      let(:link_type_code) { "LEGAL" }

      it "resets the linked_application model" do
        expect { call_save }.to change(associated_application, :copy_case).from(true).to(nil)
          .and change(associated_application, :copy_case_id).from(legal_aid_application.id).to(nil)
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { instance.save_as_draft }

    before { save_as_draft }

    context "with family link type chosen" do
      let(:link_type_code) { "FC_LEAD" }

      it "sets the lead_linked_appliction" do
        expect(legal_aid_application.lead_linked_application.link_type_code).to eq "FC_LEAD"
      end
    end

    context "with legal link type chosen" do
      let(:link_type_code) { "LEGAL" }

      it "sets the lead_linked_appliction" do
        expect(legal_aid_application.lead_linked_application.link_type_code).to eq "LEGAL"
      end
    end

    context "with link type no chosen" do
      let(:link_type_code) { false }

      it "does not create a linked application" do
        expect(legal_aid_application.lead_linked_application).to be_nil
      end
    end

    context "with link type nil" do
      let(:link_type_code) { nil }

      it "is valid" do
        expect(instance).to be_valid
      end

      it "does not update linked_application" do
        expect(legal_aid_application.lead_linked_application).to be_nil
      end
    end
  end
end
