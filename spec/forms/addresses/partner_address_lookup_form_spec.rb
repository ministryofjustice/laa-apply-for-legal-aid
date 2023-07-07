require "rails_helper"

RSpec.describe Addresses::PartnerAddressLookupForm, type: :form do
  subject(:form) { described_class.new(params) }

  let(:postcode) { "SW1H9AJ" }
  let(:partner) { build(:partner) }
  let(:params) { { postcode:, model: partner } }

  describe "validations" do
    it "has no errors with normal postcode" do
      expect(form).to be_valid
    end

    context "when postcode is invalid" do
      let(:postcode) { "invalid" }

      it "has an error on postcode" do
        expect(form).to be_invalid
        expect(form.errors[:postcode]).to contain_exactly("Enter a real postcode")
      end
    end

    context "when the postcode is not entered" do
      let(:postcode) { "" }

      it "has an error on postcode" do
        expect(form).to be_invalid
        expect(form.errors[:postcode]).to contain_exactly("Enter a postcode")
      end
    end
  end

  describe "save_as_draft" do
    before { form.save_as_draft }

    it "has no errors with normal postcode" do
      expect(form).to be_valid
    end

    context "when postcode is invalid" do
      let(:postcode) { "invalid" }

      it "has an error on postcode" do
        expect(form).to be_invalid
        expect(form.errors[:postcode]).to contain_exactly("Enter a real postcode")
      end
    end

    context "when the postcode is not entered" do
      let(:postcode) { "" }

      it "has an error on postcode" do
        expect(form).to be_valid
      end
    end
  end
end
