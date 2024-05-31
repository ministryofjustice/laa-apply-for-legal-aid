require "rails_helper"

RSpec.describe HomeAddress::DifferentAddressReasonForm, type: :form do
  subject(:instance) { described_class.new(params) }

  let(:applicant) { create(:applicant, home_address:) }
  let(:home_address) { create(:address, location: "home") }

  let(:params) do
    {
      model: applicant,
      no_fixed_residence:,
    }
  end

  describe "#save" do
    subject(:call_save) { instance.save }

    before { call_save }

    context "with yes chosen" do
      let(:no_fixed_residence) { "true" }

      it "sets no_fixed_residence to true" do
        expect(applicant.no_fixed_residence?).to be true
      end

      it "destroys any existing home address" do
        expect(applicant.reload.home_address).to be_nil
      end
    end

    context "with no chosen" do
      let(:no_fixed_residence) { "false" }

      it "sets no_fixed_residence to true" do
        expect(applicant.no_fixed_residence?).to be false
      end

      it "does not destroy any existing home address" do
        expect(applicant.home_address).to eq home_address
      end
    end

    context "with no answer chosen" do
      let(:no_fixed_residence) { "" }

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

      it "destroys any existing home address" do
        expect(applicant.reload.home_address).to be_nil
      end
    end

    context "with no chosen" do
      let(:no_fixed_residence) { "false" }

      it "sets no_fixed_residence to true" do
        expect(applicant.no_fixed_residence?).to be false
      end

      it "does not destroy any existing home address" do
        expect(applicant.reload.home_address).to eq home_address
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
