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

    before { call_save }

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

      it "is invalid" do
        expect(instance).not_to be_valid
      end

      it "adds custom blank error message" do
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Select if you want to link this application with another one")
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
