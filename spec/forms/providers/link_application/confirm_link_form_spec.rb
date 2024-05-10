require "rails_helper"

RSpec.describe Providers::LinkApplication::ConfirmLinkForm, type: :form do
  subject(:instance) { described_class.new(params) }

  let(:linked_application) { LinkedApplication.create!(lead_application_id: lead_application.id, associated_application_id: legal_aid_application.id, link_type_code: "FC_LEAD") }

  let(:params) do
    {
      confirm_link:,
      model: linked_application,
    }
  end
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:lead_application) { create(:legal_aid_application) }

  describe "#save" do
    subject(:call_save) { instance.save }

    before { call_save }

    context "with confirm_link true" do
      let(:confirm_link) { "true" }

      it "sets link_case to true" do
        expect(linked_application.confirm_link).to be true
      end
    end

    context "with confirm_link false" do
      let(:confirm_link) { "false" }

      it "sets confirm_link to false" do
        expect(linked_application.confirm_link).to be false
      end
    end

    context "with confirm_link No" do
      let(:confirm_link) { "No" }

      it "sets confirm_link to nil" do
        expect(linked_application.confirm_link).to be_nil
      end

      it "does not not destroy the linked application" do
        expect(legal_aid_application.reload.lead_application).to eq lead_application
      end
    end

    context "with confirm_link nil" do
      let(:confirm_link) { "" }

      it "is invalid" do
        expect(instance).not_to be_valid
      end

      it "adds custom blank error message" do
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Select if you want to link to the application")
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { instance.save_as_draft }

    before { save_as_draft }

    context "with confirm_link true" do
      let(:confirm_link) { "true" }

      it "sets confirm_link to true" do
        expect(linked_application.confirm_link).to be true
      end
    end

    context "with confirm_link false" do
      let(:confirm_link) { "false" }

      it "sets confirm_link to true" do
        expect(linked_application.confirm_link).to be false
      end
    end

    context "with confirm_link No" do
      let(:confirm_link) { "No" }

      it "sets confirm_link to nil" do
        expect(linked_application.confirm_link).to be_nil
      end
    end

    context "with confirm_link nil" do
      let(:confirm_link) { "" }

      it "is valid" do
        expect(instance).to be_valid
      end

      it "does not confirm_link" do
        expect(linked_application.confirm_link).to be_nil
      end
    end
  end
end
