require "rails_helper"

RSpec.describe Providers::LinkApplication::ConfirmLinkForm, type: :form do
  subject(:instance) { described_class.new(params) }

  before { LinkedApplication.create!(lead_application_id: lead_application.id, associated_application_id: legal_aid_application.id, link_type_code: "FC_LEAD") }

  let(:params) do
    {
      link_case:,
      model: legal_aid_application,
    }
  end
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:lead_application) { create(:legal_aid_application) }

  describe "#save" do
    subject(:call_save) { instance.save }

    before { call_save }

    context "with link_case true" do
      let(:link_case) { "true" }

      it "sets link_case to true" do
        expect(legal_aid_application.reload.link_case).to be true
      end

      it "does not not destroy the linked application" do
        expect(legal_aid_application.reload.lead_application).to eq lead_application
      end
    end

    context "with link_case false" do
      let(:link_case) { "false" }

      it "sets link_case to true" do
        expect(legal_aid_application.reload.link_case).to be false
      end

      it "destroys the linked application" do
        expect(legal_aid_application.reload.lead_application).to be_nil
      end
    end

    context "with link_case No" do
      let(:link_case) { "No" }

      it "sets link_case to nil" do
        expect(legal_aid_application.reload.link_case).to be_nil
      end

      it "does not not destroy the linked application" do
        expect(legal_aid_application.reload.lead_application).to eq lead_application
      end
    end

    context "with link type nil" do
      let(:link_case) { "" }

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

    context "with link_case true" do
      let(:link_case) { "true" }

      it "sets link_case to true" do
        expect(legal_aid_application.reload.link_case).to be true
      end

      it "does not not destroy the linked application" do
        expect(legal_aid_application.reload.lead_application).to eq lead_application
      end
    end

    context "with link_case false" do
      let(:link_case) { "false" }

      it "sets link_case to true" do
        expect(legal_aid_application.reload.link_case).to be false
      end

      it "destroys the linked application" do
        expect(legal_aid_application.reload.lead_application).to be_nil
      end
    end

    context "with link_case No" do
      let(:link_case) { "No" }

      it "sets link_case to nil" do
        expect(legal_aid_application.reload.link_case).to be_nil
      end

      it "does not not destroy the linked application" do
        expect(legal_aid_application.reload.lead_application).to eq lead_application
      end
    end

    context "with link type nil" do
      let(:link_case) { "" }

      it "is valid" do
        expect(instance).to be_valid
      end

      it "does not update link_case" do
        expect(legal_aid_application.reload.link_case).to be_nil
      end

      it "does not not destroy the linked application" do
        expect(legal_aid_application.reload.lead_application).to eq lead_application
      end
    end
  end
end
