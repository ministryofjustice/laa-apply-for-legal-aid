require "rails_helper"

RSpec.describe LegalAidApplications::ConfirmClientDeclarationForm do
  subject(:form) { described_class.new(params) }

  let(:client_declaration_confirmed) { true }
  let(:params) do
    {
      client_declaration_confirmed:,
    }
  end

  describe "valid?" do
    it "returns true when validations pass" do
      expect(form).to be_valid
    end

    context "when invalid" do
      let(:client_declaration_confirmed) { nil }

      it "returns false when validations fail" do
        expect(form).not_to be_valid
      end
    end
  end
end
