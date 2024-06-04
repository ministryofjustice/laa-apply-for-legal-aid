require "rails_helper"

RSpec.describe Addresses::ChoiceForm, type: :form do
  subject(:form) { described_class.new(form_params.merge(model: applicant)) }

  let(:correspondence_address_choice) { "home" }
  let(:applicant) { create(:applicant) }
  let(:form_params) do
    {
      correspondence_address_choice:,
    }
  end

  describe "validations" do
    it "is valid with all the required attributes" do
      expect(form).to be_valid
    end

    context "when correspondence_address_choice is blank" do
      let(:correspondence_address_choice) { "" }

      it "contains a presence error on the correspondence_address_choice" do
        expect(form).not_to be_valid
        expect(form.errors[:correspondence_address_choice]).to contain_exactly("Select where we should send your client's correspondence")
      end
    end

    context "when correspondence_address_choice is maliciously wrong" do
      let(:correspondence_address_choice) { "wrong" }

      it "contains a presence error on the correspondence_address_choice" do
        expect(form).not_to be_valid
        expect(form.errors[:correspondence_address_choice]).to contain_exactly("Select where we should send your client's correspondence")
      end
    end
  end
end
