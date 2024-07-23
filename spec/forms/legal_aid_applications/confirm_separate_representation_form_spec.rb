require "rails_helper"

RSpec.describe LegalAidApplications::ConfirmSeparateRepresentationForm do
  subject(:form) { described_class.new(params) }

  describe "#save" do
    let(:legal_aid_application) { create(:legal_aid_application, separate_representation_required: nil) }

    before do
      form.save
    end

    context "when separate represenation required is confirmed" do
      let(:params) { { separate_representation_required: true, model: legal_aid_application } }

      it "updates the application" do
        expect(legal_aid_application.separate_representation_required).to be true
      end

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when separate representation required is not confirmed" do
      let(:params) { { separate_representation_required: "", model: legal_aid_application } }

      it "does not update the application" do
        expect(legal_aid_application.separate_representation_required).to be_nil
      end

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors.messages[:separate_representation_required]).to include("Confirm your client wants separate representation")
      end
    end
  end

  describe "#save_as_draft" do
    let(:legal_aid_application) { create(:legal_aid_application, separate_representation_required: nil) }

    before do
      form.save_as_draft
    end

    context "when separate representation required is confirmed" do
      let(:params) { { separate_representation_required: true, model: legal_aid_application } }

      it "updates the application" do
        expect(legal_aid_application.separate_representation_required).to be true
      end
    end

    context "when separate representation required is not confirmed" do
      let(:params) { { separate_representation_required: "", model: legal_aid_application } }

      it "does not update the application" do
        expect(legal_aid_application.separate_representation_required).to be_nil
      end

      it "is valid" do
        expect(form).to be_valid
      end
    end
  end
end
