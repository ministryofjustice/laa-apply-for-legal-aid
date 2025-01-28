require "rails_helper"

RSpec.describe Providers::ApplicationMeritsTask::MatterOpposedForm do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:params) { { model: build(:matter_opposition, legal_aid_application:), matter_opposed: } }

  describe "#validate" do
    subject(:form) { described_class.new(params) }

    context "when matter_opposed is blank" do
      let(:matter_opposed) { nil }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors).to be_added(:matter_opposed, :inclusion, value: nil)
      end
    end

    context "when matter_opposed is true" do
      let(:matter_opposed) { "true" }

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when matter_opposed is false" do
      let(:matter_opposed) { "false" }

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
      let(:matter_opposed) { nil }

      it "does not create a matter opposition record" do
        expect(matter_opposition).to be_nil
      end
    end

    context "when the form is passed true" do
      let(:matter_opposed) { "true" }

      it "creates a matter opposition record" do
        expect(matter_opposition).to have_attributes(
          legal_aid_application_id: legal_aid_application.id,
          matter_opposed: true,
        )
      end
    end

    context "when the form is passed false" do
      let(:matter_opposed) { "false" }

      it "creates a matter opposition record" do
        expect(matter_opposition).to have_attributes(
          legal_aid_application_id: legal_aid_application.id,
          matter_opposed: false,
        )
      end
    end
  end
end
