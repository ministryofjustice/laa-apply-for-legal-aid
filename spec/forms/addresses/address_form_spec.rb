require "rails_helper"

RSpec.describe Addresses::AddressForm, type: :form do
  subject(:form) { described_class.new(address_params.merge(model: address)) }

  let(:address_line_one) { "Ministry Of Justice" }
  let(:address_line_two) { "102 Petty France" }
  let(:address_line_three) { "" }
  let(:city) { "London" }
  let(:county) { "" }
  let(:postcode) { "SW1H 9AJ" }
  let(:applicant) { create(:applicant) }
  let(:address) { applicant.build_address }
  let(:applicant_id) { applicant.id }
  let(:address_params) do
    {
      address_line_one:,
      address_line_two:,
      address_line_three:,
      city:,
      county:,
      postcode:,
    }
  end

  describe "validations" do
    it "is valid with all the required attributes" do
      expect(form).to be_valid
    end

    describe "Address line 1" do
      context "when Address line 1 is blank" do
        let(:address_line_one) { "" }

        it "returns an presence error on line one" do
          expect(form).not_to be_valid
          expect(form.errors[:address_line_one]).to contain_exactly("Enter the first line of the address")
        end
      end
    end

    describe "City" do
      context "when city field is blank" do
        let(:city) { "" }

        it "returns an presence error on city field" do
          expect(form).not_to be_valid
          expect(form.errors[:city]).to contain_exactly("Enter a town or city")
        end
      end

      context "when an invalid input has been entered" do
        let(:city) { "12city" }

        it "returns an error on city field" do
          expect(form).not_to be_valid
          expect(form.errors[:city]).to contain_exactly("Enter a real town or city")
        end
      end
    end

    describe "County" do
      context "when an invalid input has been entered" do
        let(:county) { "12county" }

        it "returns an error on county field" do
          expect(form).not_to be_valid
          expect(form.errors[:county]).to contain_exactly("Enter a real county")
        end
      end
    end

    describe "Postcode" do
      context "when postcode field is blank" do
        let(:postcode) { "" }

        it "returns an presence error on postcode field" do
          expect(form).not_to be_valid
          expect(form.errors[:postcode]).to contain_exactly("Enter a postcode in the correct format")
        end
      end
    end
  end

  describe "#save" do
    it "creates a new address for the applicant with the provided attributes" do
      expect { form.save }.to change { applicant.reload.addresses.count }.by(1)

      address = applicant.addresses.last
      expect(address.address_line_one).to eq(address_line_one)
      expect(address.address_line_two).to eq(address_line_two)
      expect(address.city).to eq(city)
      expect(address.county).to eq(county)
      expect(address.postcode).to eq(postcode)
    end

    context "when the form is not valid" do
      let(:city) { "" }

      it "does not create a new address for the applicant" do
        expect { form.save }.not_to change { applicant.reload.addresses.count }
      end
    end
  end

  describe "save_as_draft" do
    it "creates a new address for the applicant with the provided attributes" do
      expect { form.save_as_draft }.to change { applicant.reload.addresses.count }.by(1)

      address = applicant.addresses.last
      expect(address.address_line_one).to eq(address_line_one)
      expect(address.address_line_two).to eq(address_line_two)
      expect(address.city).to eq(city)
      expect(address.county).to be_nil
      expect(address.postcode).to eq(postcode)
    end

    context "when a city is empty" do
      let(:city) { "" }

      it "creates a new address for the applicant" do
        expect { form.save_as_draft }.to change { applicant.reload.addresses.count }.by(1)
      end
    end

    context "when address one and two are blank" do
      let(:address_line_one) { "" }
      let(:address_line_two) { "" }

      it "creates a new address for the applicant" do
        expect { form.save_as_draft }.to change { applicant.reload.addresses.count }.by(1)
      end
    end

    context "when an entry is invalid" do
      let(:postcode) { "invalid" }

      it "does not create a new address for the applicant" do
        expect { form.save }.not_to change { applicant.reload.addresses.count }
      end
    end
  end
end
