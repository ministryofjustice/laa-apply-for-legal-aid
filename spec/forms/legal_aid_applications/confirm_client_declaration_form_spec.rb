require "rails_helper"

RSpec.describe LegalAidApplications::ConfirmClientDeclarationForm do
  subject(:form) { described_class.new(params) }

  describe "#validates" do
    context "when the client declaration is confirmed" do
      let(:params) { { client_declaration_confirmed: true } }

      it { is_expected.to be_valid }
    end

    context "when the client declaration is not confirmed" do
      let(:params) { { client_declaration_confirmed: "" } }

      it "is invalid" do
        expect(form).to be_invalid
        expect(form.errors).to be_added(:client_declaration_confirmed, :accepted)
      end
    end
  end

  describe "#save" do
    let(:legal_aid_application) do
      create(:legal_aid_application, client_declaration_confirmed_at: nil)
    end

    before do
      freeze_time
      form.save!
    end

    context "when the client declaration is confirmed" do
      let(:params) do
        { client_declaration_confirmed: true, model: legal_aid_application }
      end

      it "updates the application" do
        expect(legal_aid_application.client_declaration_confirmed_at)
          .to eq Time.current
      end
    end

    context "when the client declaration is not confirmed" do
      let(:params) do
        { client_declaration_confirmed: "", model: legal_aid_application }
      end

      it "does not update the application" do
        expect(legal_aid_application.client_declaration_confirmed_at).to be_nil
      end
    end
  end
end
