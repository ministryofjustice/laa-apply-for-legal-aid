require "rails_helper"

RSpec.describe Addresses::NonUkHomeAddressForm, :vcr, type: :form do
  subject(:form) { described_class.new(address_params.merge(model: address)) }

  let(:country_code) { "CHN" }
  let(:country_name) { "China" }
  let(:address_line_one) { "Maple Leaf Education Building" }
  let(:address_line_two) { "No. 13 Baolong 1st Road" }
  let(:city) { "Longgang District" }
  let(:county) { "Shenzhen City, Guangdong Province" }
  let(:applicant) { create(:applicant) }
  let(:address) { applicant.build_address }
  let(:applicant_id) { applicant.id }
  let(:address_params) do
    {
      country_code:,
      address_line_one:,
      address_line_two:,
      city:,
      county:,
    }
  end

  describe "validations" do
    it "is valid with all the required attributes" do
      expect(form).to be_valid
    end

    describe "Country" do
      context "when country field is blank" do
        let(:country_code) { "" }

        it "returns a presence error on country field" do
          expect(form).not_to be_valid
          expect(form.errors[:country_code]).to contain_exactly("Search for and select a country")
        end
      end

      context "when country field is populated with an invalid country" do
        let(:country_code) { "invalid" }

        it "returns a presence error on country field" do
          expect(form).not_to be_valid
          expect(form.errors[:country_code]).to contain_exactly("Search for and select a country")
        end
      end
    end

    describe "Address line one" do
      context "when Address line one is blank" do
        let(:address_line_one) { "" }

        it "returns an presence error on line one" do
          expect(form).not_to be_valid
          expect(form.errors[:address_line_one]).to contain_exactly("Enter the first line of the address")
        end
      end
    end

    context "when the form is not valid" do
      let(:address_line_one) { "" }

      it "does not create a new address for the applicant" do
        expect { form.save }.not_to change { applicant.reload.addresses.count }
      end
    end
  end

  describe "#save" do
    it "creates a new address for the applicant with the provided attributes" do
      expect { form.save }.to change { applicant.reload.addresses.count }.by(1)

      address = applicant.addresses.last
      expect(address.country_code).to eq(country_code)
      expect(address.address_line_one).to eq(address_line_one)
      expect(address.address_line_two).to eq(address_line_two)
      expect(address.city).to eq(city)
      expect(address.county).to eq(county)
      expect(address.country_name).to eq(country_name)
    end

    context "when the form is not valid" do
      let(:address_line_one) { "" }

      it "does not create a new address for the applicant" do
        expect { form.save }.not_to change { applicant.reload.addresses.count }
      end
    end
  end

  describe "save_as_draft" do
    it "creates a new address for the applicant with the provided attributes" do
      expect { form.save_as_draft }.to change { applicant.reload.addresses.count }.by(1)

      address = applicant.addresses.last
      expect(address.country_name).to eq(country_name)
      expect(address.country_code).to eq(country_code)
      expect(address.address_line_one).to eq(address_line_one)
      expect(address.address_line_two).to eq(address_line_two)
      expect(address.city).to eq(city)
      expect(address.county).to eq(county)
    end

    context "when a country is empty" do
      let(:country_code) { "" }

      it "creates a new address for the applicant" do
        expect { form.save_as_draft }.to change { applicant.reload.addresses.count }.by(1)
      end
    end

    context "when country and address one are blank" do
      let(:country_code) { "" }
      let(:address_line_one) { "" }

      it "creates a new address for the applicant" do
        expect { form.save_as_draft }.to change { applicant.reload.addresses.count }.by(1)
      end
    end

    context "when an entry is invalid" do
      let(:address_line_one) { "invalid" }

      it "creates a new address for the applicant" do
        expect { form.save_as_draft }.to change { applicant.reload.addresses.count }.by(1)
      end
    end
  end
end
