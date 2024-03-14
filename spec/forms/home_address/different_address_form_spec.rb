require "rails_helper"

RSpec.describe HomeAddress::DifferentAddressForm, type: :form do
  subject(:instance) { described_class.new(params) }

  let(:applicant) { create(:applicant, home_address:) }
  let(:home_address) { create(:address, location: "home") }

  let(:params) do
    {
      model: applicant,
      same_correspondence_and_home_address:,
    }
  end

  describe "#save" do
    subject(:call_save) { instance.save }

    before { call_save }

    context "with yes chosen" do
      let(:same_correspondence_and_home_address) { "true" }

      it "sets same_correspondence_and_home_address to true" do
        expect(applicant.same_correspondence_and_home_address?).to be true
      end

      it "destroys any existing home address" do
        expect(applicant.reload.home_address).to be_nil
      end
    end

    context "with no chosen" do
      let(:same_correspondence_and_home_address) { "false" }

      it "sets same_correspondence_and_home_address to true" do
        expect(applicant.same_correspondence_and_home_address?).to be false
      end

      it "does not destroy any existing home address" do
        expect(applicant.home_address).to eq home_address
      end
    end

    context "with no answer chosen" do
      let(:same_correspondence_and_home_address) { "" }

      it "is invalid" do
        expect(instance).not_to be_valid
      end

      it "adds custom blank error message" do
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Select yes if this is your client's home address")
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { instance.save_as_draft }

    before { save_as_draft }

    context "with yes chosen" do
      let(:same_correspondence_and_home_address) { "true" }

      it "sets same_correspondence_and_home_address to true" do
        expect(applicant.same_correspondence_and_home_address?).to be true
      end

      it "destroys any existing home address" do
        expect(applicant.reload.home_address).to be_nil
      end
    end

    context "with no chosen" do
      let(:same_correspondence_and_home_address) { "false" }

      it "sets same_correspondence_and_home_address to true" do
        expect(applicant.same_correspondence_and_home_address?).to be false
      end

      it "does not destroy any existing home address" do
        expect(applicant.reload.home_address).to eq home_address
      end
    end

    context "with no answer chosen" do
      let(:same_correspondence_and_home_address) { "" }

      it "is valid" do
        expect(instance).to be_valid
      end

      it "does not update same_correspondence_and_home_addresss" do
        expect(applicant.same_correspondence_and_home_address).to be_nil
      end
    end
  end
end
