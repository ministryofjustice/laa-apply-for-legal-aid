require "rails_helper"

RSpec.describe Addresses::AddressSelectionForm, type: :form do
  subject(:form) { described_class.new(form_params.merge(model: applicant)) }

  let(:postcode) { "SW1H 9EA" }
  let(:lookup_id) { "123456" }
  let(:applicant) { create(:applicant) }
  let(:form_params) do
    {
      lookup_id:,
      postcode:,
      addresses: [Address.new(lookup_id:)],
    }
  end

  describe "validations" do
    it "is valid with all the required attributes" do
      expect(form).to be_valid
    end

    context "when lookup_id is blank" do
      let(:lookup_id) { "" }

      it "contains a presence error on the lookup_id" do
        expect(form).not_to be_valid
        expect(form.errors[:lookup_id]).to contain_exactly("Select an address from the list")
      end
    end
  end
end
