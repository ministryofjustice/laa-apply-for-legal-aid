require "rails_helper"

RSpec.describe Addresses::PartnerAddressForm, type: :form do
  subject(:form) { described_class.new(address_params.merge(model: partner)) }

  let(:partner) { create(:partner) }
  let(:address_line_one) { "Ministry Of Justice" }
  let(:address_line_two) { "102 Petty France" }
  let(:city) { "London" }
  let(:county) { "" }
  let(:postcode) { "SW1H 9AJ" }
  let(:address_params) do
    {
      address_line_one:,
      address_line_two:,
      city:,
      county:,
      postcode:,
    }
  end

  describe "validations" do
    it "is valid with all the required attributes" do
      expect(form).to be_valid
    end

    describe "Building and street" do
      context "when both fields are blank" do
        let(:address_line_one) { "" }
        let(:address_line_two) { "" }

        it "returns an presence error on line one and line two" do
          expect(form).not_to be_valid
          expect(form.errors[:address_line_one]).to match_array(["Enter a building and street"])
        end
      end

      context "when line one is blank" do
        let(:address_line_one) { "" }

        it "form is valid" do
          expect(form).to be_valid
        end
      end

      context "when line two is blank" do
        let(:address_line_two) { "" }

        it "form is valid" do
          expect(form).to be_valid
        end
      end
    end

    describe "City" do
      context "when city field is blank" do
        let(:city) { "" }

        it "returns an presence error on city field" do
          expect(form).not_to be_valid
          expect(form.errors[:city]).to match_array(["Enter a town or city"])
        end
      end
    end

    describe "Postcode" do
      context "when postcode field is blank" do
        let(:postcode) { "" }

        it "returns an presence error on postcode field" do
          expect(form).not_to be_valid
          expect(form.errors[:postcode]).to match_array(["Enter a postcode"])
        end
      end
    end
  end

  describe "#save" do
    subject(:form_save) { form.save }

    it "creates a new address for the applicant with the provided attributes" do
      form_save

      expect(partner.address_line_one).to eq(address_line_one)
      expect(partner.address_line_two).to eq(address_line_two)
      expect(partner.city).to eq(city)
      expect(partner.county).to eq(county)
      expect(partner.postcode).to eq(postcode)
    end

    context "when the form is not valid" do
      let(:city) { "" }

      it "does not create a new address for the applicant" do
        expect { form_save }.not_to change { partner.reload.address_line_one }
      end
    end
  end

  describe "save_as_draft" do
    subject(:form_save_as_draft) { form.save_as_draft }

    it "creates a new address for the applicant with the provided attributes" do
      form_save_as_draft

      expect(partner.address_line_one).to eq(address_line_one)
      expect(partner.address_line_two).to eq(address_line_two)
      expect(partner.city).to eq(city)
      expect(partner.county).to be_nil
      expect(partner.postcode).to eq(postcode)
    end

    context "when fields are empty" do
      let(:address_line_one) { "1 A Street" }
      let(:address_line_two) { "" }
      let(:city) { "" }

      it "updates the populated partner address fields" do
        form_save_as_draft
        expect(partner.reload).to have_attributes(
          address_line_one:,
          address_line_two: nil,
          city: nil,
          county: nil,
          postcode:,
        )
      end
    end

    context "when an entry is invalid" do
      let(:postcode) { "invalid" }

      it "does not update any fields on the partner" do
        form_save_as_draft
        expect(partner.reload).to have_attributes(
          address_line_one: nil,
          address_line_two: nil,
          city: nil,
          county: nil,
          postcode: nil,
        )
      end
    end
  end
end
