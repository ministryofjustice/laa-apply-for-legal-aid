require "rails_helper"

RSpec.describe Proceedings::ClientInvolvementTypeForm, :vcr, type: :form do
  subject(:cit_form) { described_class.new(form_params) }

  let(:proceeding) { create(:proceeding, :da001, :with_cit_z) }
  let(:params) do
    {
      client_involvement_type_ccms_code: cit,
    }
  end
  let(:form_params) { params.merge(model: proceeding, cit_types:) }
  let(:cit_types) do
    [
      LegalFramework::ClientInvolvementTypes::Proceeding::ClientInvolvementTypeStruct.new(
        "ccms_code" => "A",
        "description" => "Applicant, claimant or petitioner",
      ),
      LegalFramework::ClientInvolvementTypes::Proceeding::ClientInvolvementTypeStruct.new(
        "ccms_code" => "D",
        "description" => "Defendant or respondent",
      ),
      LegalFramework::ClientInvolvementTypes::Proceeding::ClientInvolvementTypeStruct.new(
        "ccms_code" => "W",
        "description" => "A child subject of the proceeding",
      ),
      LegalFramework::ClientInvolvementTypes::Proceeding::ClientInvolvementTypeStruct.new(
        "ccms_code" => "I",
        "description" => "Intervenor",
      ),
      LegalFramework::ClientInvolvementTypes::Proceeding::ClientInvolvementTypeStruct.new(
        "ccms_code" => "Z",
        "description" => "Joined party",
      ),
    ]
  end

  describe "#save" do
    subject(:save_form) { cit_form.save }

    before { save_form }

    context "when the client_involvement_type submitted is valid" do
      let(:cit) { "A" }

      it "updates the proceeding" do
        expect(proceeding.reload.client_involvement_type_ccms_code).to eq "A"
      end
    end

    context "when the client_involvement_type submitted is missing" do
      let(:cit) { "" }

      it "is invalid" do
        expect(cit_form).not_to be_valid
      end

      it "generates the expected error message" do
        expect(cit_form.errors.map(&:attribute)).to eq [:client_involvement_type_ccms_code]
      end
    end
  end
end
