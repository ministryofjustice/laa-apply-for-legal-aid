require "rails_helper"

RSpec.describe Partner do
  subject(:partner) { described_class.create(legal_aid_application:) }

  let(:legal_aid_application) { create(:legal_aid_application) }

  describe ".duplicate_applicants_address" do
    subject(:duplicate_applicants_address) { partner.duplicate_applicants_address }

    context "when an applicant with an address exists" do
      let!(:applicant) { create(:applicant, :with_address, legal_aid_application:) }

      before { duplicate_applicants_address }

      it "duplicates the address data into the partner record" do
        expect(partner.reload).to have_attributes(
          address_line_one: applicant.address.address_line_one,
          address_line_two: applicant.address.address_line_two,
          city: applicant.address.city,
          county: applicant.address.county,
          postcode: applicant.address.postcode,
          organisation: applicant.address.organisation,
        )
      end
    end
  end
end
