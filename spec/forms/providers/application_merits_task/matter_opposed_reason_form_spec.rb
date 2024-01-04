require "rails_helper"

RSpec.describe Providers::ApplicationMeritsTask::MatterOpposedReasonForm do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:params) { { reason:, legal_aid_application_id: legal_aid_application.id } }

  describe "#validate" do
    subject(:form) { described_class.new(params) }

    context "when reason is blank" do
      let(:reason) { nil }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors).to be_added(:reason, :blank)
      end
    end

    context "when reason is not blank" do
      let(:reason) { "A reason to oppose the matter" }

      it "is valid" do
        expect(form).to be_valid
      end
    end
  end

  describe "#save" do
    subject(:save_form) { described_class.new(params).save }

    let(:matter_opposition) { legal_aid_application.matter_opposition }

    before { save_form }

    context "when the form is invalid" do
      let(:reason) { nil }

      it "does not create a matter opposition record" do
        expect(matter_opposition).to be_nil
      end
    end

    context "when the form is valid" do
      let(:reason) { "A reason to oppose the matter" }

      it "creates a matter opposition record" do
        expect(matter_opposition).to have_attributes(
          legal_aid_application_id: legal_aid_application.id,
          reason:,
        )
      end
    end
  end
end
