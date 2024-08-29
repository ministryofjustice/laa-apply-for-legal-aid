require "rails_helper"

RSpec.describe HomeAddress::StatusForm, type: :form do
  subject(:instance) { described_class.new(params) }

  let(:applicant) { create(:applicant) }
  let(:params) do
    {
      model: applicant,
      no_fixed_residence:,
    }
  end

  describe "#save" do
    subject(:call_save) { instance.save }

    context "with yes chosen" do
      let(:no_fixed_residence) { "true" }

      it "sets no_fixed_residence to true" do
        call_save
        expect(applicant.no_fixed_residence?).to be true
      end

      context "when changing from another option to no" do
        let(:applicant) { create(:applicant, :with_address) }

        it "clears previously entered home address information" do
          expect { call_save }.to change(applicant, :home_address).to(nil)
        end
      end
    end

    context "with no chosen" do
      let(:no_fixed_residence) { "false" }

      it "sets no_fixed_residence to false" do
        call_save
        expect(applicant.no_fixed_residence?).to be false
      end
    end

    context "with no answer chosen" do
      let(:no_fixed_residence) { "" }

      before { call_save }

      it "is invalid" do
        expect(instance).not_to be_valid
      end

      it "adds custom blank error message" do
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Select yes if your client has a home address")
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { instance.save_as_draft }

    before { save_as_draft }

    context "with yes chosen" do
      let(:no_fixed_residence) { "true" }

      it "sets no_fixed_residence to true" do
        expect(applicant.no_fixed_residence?).to be true
      end
    end

    context "with no chosen" do
      let(:no_fixed_residence) { "false" }

      it "sets no_fixed_residence to false" do
        expect(applicant.no_fixed_residence?).to be false
      end
    end

    context "with no answer chosen" do
      let(:no_fixed_residence) { "" }

      it "is valid" do
        expect(instance).to be_valid
      end

      it "does not update no_fixed_residences" do
        expect(applicant.no_fixed_residence).to be_nil
      end
    end
  end
end
