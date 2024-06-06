require "rails_helper"

RSpec.describe Addresses::CareOfForm, type: :form do
  subject(:instance) { described_class.new(params) }

  let(:address) { create(:address, location: "correspondence") }
  let(:care_of) { "no" }

  let(:params) do
    {
      model: address,
      care_of:,
      care_of_first_name:,
      care_of_last_name:,
      care_of_organisation_name:,
    }
  end

  describe "#save" do
    subject(:call_save) { instance.save }

    before { call_save }

    context "with care of person chosen" do
      let(:care_of) { "person" }
      let(:care_of_last_name) { "Smith" }
      let(:care_of_first_name) { "Bob" }
      let(:care_of_organisation_name) { nil }

      it "updates the address care_of fields" do
        expect(address.care_of).to eq "person"
        expect(address.care_of_last_name).to eq "Smith"
        expect(address.care_of_first_name).to eq "Bob"
        expect(address.care_of_organisation_name).to be_nil
      end
    end

    context "with care of organisation chosen" do
      let(:care_of) { "organisation" }
      let(:care_of_last_name) { nil }
      let(:care_of_first_name) { nil }
      let(:care_of_organisation_name) { "An Organisation Name" }

      it "updates the address care_of fields" do
        expect(address.care_of).to eq "organisation"
        expect(address.care_of_last_name).to be_nil
        expect(address.care_of_first_name).to be_nil
        expect(address.care_of_organisation_name).to eq "An Organisation Name"
      end
    end

    context "with no chosen" do
      let(:care_of) { "no" }
      let(:care_of_last_name) { nil }
      let(:care_of_first_name) { nil }
      let(:care_of_organisation_name) { nil }

      it "updates the address care_of fields" do
        expect(address.care_of).to eq "no"
        expect(address.care_of_last_name).to be_nil
        expect(address.care_of_first_name).to be_nil
        expect(address.care_of_organisation_name).to be_nil
      end
    end

    context "with no answer chosen" do
      let(:care_of) { nil }
      let(:care_of_last_name) { nil }
      let(:care_of_first_name) { nil }
      let(:care_of_organisation_name) { nil }

      it "is invalid" do
        expect(instance).not_to be_valid
      end

      it "adds custom blank error message" do
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Select if you want to add a 'care of' recipient for your client's email")
      end
    end

    context "with missing person name" do
      let(:care_of) { "person" }
      let(:care_of_last_name) { "Smith" }
      let(:care_of_first_name) { nil }
      let(:care_of_organisation_name) { nil }

      it "is invalid" do
        expect(instance).not_to be_valid
      end

      it "adds custom blank error message" do
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Enter the recipient's first name")
      end
    end

    context "with missing organisation name" do
      let(:care_of) { "organisation" }
      let(:care_of_last_name) { nil }
      let(:care_of_first_name) { nil }
      let(:care_of_organisation_name) { nil }

      it "is invalid" do
        expect(instance).not_to be_valid
      end

      it "adds custom blank error message" do
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Enter the organisation name")
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { instance.save_as_draft }

    before { save_as_draft }

    context "with care of person chosen" do
      let(:care_of) { "person" }
      let(:care_of_last_name) { "Smith" }
      let(:care_of_first_name) { "Bob" }
      let(:care_of_organisation_name) { nil }

      it "updates the address care_of fields" do
        expect(address.care_of).to eq "person"
        expect(address.care_of_last_name).to eq "Smith"
        expect(address.care_of_first_name).to eq "Bob"
        expect(address.care_of_organisation_name).to be_nil
      end
    end

    context "with care of organisation chosen" do
      let(:care_of) { "organisation" }
      let(:care_of_last_name) { nil }
      let(:care_of_first_name) { nil }
      let(:care_of_organisation_name) { "An Organisation Name" }

      it "updates the address care_of fields" do
        expect(address.care_of).to eq "organisation"
        expect(address.care_of_last_name).to be_nil
        expect(address.care_of_first_name).to be_nil
        expect(address.care_of_organisation_name).to eq "An Organisation Name"
      end
    end

    context "with no chosen" do
      let(:care_of) { "no" }
      let(:care_of_last_name) { nil }
      let(:care_of_first_name) { nil }
      let(:care_of_organisation_name) { nil }

      it "updates the address care_of fields" do
        expect(address.care_of).to eq "no"
        expect(address.care_of_last_name).to be_nil
        expect(address.care_of_first_name).to be_nil
        expect(address.care_of_organisation_name).to be_nil
      end
    end

    context "with no answer chosen" do
      let(:care_of) { nil }
      let(:care_of_last_name) { nil }
      let(:care_of_first_name) { nil }
      let(:care_of_organisation_name) { nil }

      it "is valid" do
        expect(instance).to be_valid
      end

      it "does not update the care_of" do
        expect(address.care_of).to be_nil
      end
    end

    context "with missing person name" do
      let(:care_of) { "person" }
      let(:care_of_last_name) { nil }
      let(:care_of_first_name) { "Bob" }
      let(:care_of_organisation_name) { nil }

      it "is valid" do
        expect(instance).to be_valid
      end

      it "updates the address care_of fields" do
        expect(address.care_of).to eq "person"
        expect(address.care_of_last_name).to be_nil
        expect(address.care_of_first_name).to eq "Bob"
        expect(address.care_of_organisation_name).to be_nil
      end
    end

    context "with missing organisation name" do
      let(:care_of) { "organisation" }
      let(:care_of_last_name) { nil }
      let(:care_of_first_name) { nil }
      let(:care_of_organisation_name) { nil }

      it "is valid" do
        expect(instance).to be_valid
      end

      it "updates the address care_of fields" do
        expect(address.care_of).to eq "organisation"
        expect(address.care_of_last_name).to be_nil
        expect(address.care_of_first_name).to be_nil
        expect(address.care_of_organisation_name).to be_nil
      end
    end
  end
end
