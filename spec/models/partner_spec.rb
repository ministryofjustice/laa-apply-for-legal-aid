require "rails_helper"

RSpec.describe Partner do
  subject(:new_partner) { described_class.create(legal_aid_application:) }

  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "on validation" do
    before do
      new_partner.first_name = "John"
      new_partner.last_name = "Doe"
      new_partner.date_of_birth = Date.new(1988, 0o2, 0o1)
      new_partner.national_insurance_number = "AB123456D"
    end

    it "is valid with all valid attributes" do
      expect(new_partner).to be_valid
    end
  end
end
