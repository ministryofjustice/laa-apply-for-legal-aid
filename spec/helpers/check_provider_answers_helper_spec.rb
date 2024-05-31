require "rails_helper"

RSpec.describe CheckProviderAnswersHelper do
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant, address:, same_correspondence_and_home_address:, no_fixed_residence:) }
  let(:address) { create(:address, lookup_used:) }
  let(:lookup_used) { false }
  let(:same_correspondence_and_home_address) { false }
  let(:no_fixed_abode) { false }
  let(:no_fixed_residence) { false }

  describe ".change_address_link" do
    subject(:link) { helper.change_address_link(legal_aid_application, location) }

    context "when location is home" do
      let(:location) { "home" }

      it "returns the home_address_different_address path" do
        expect(link).to eq "/providers/applications/#{legal_aid_application.id}/home_address/status?locale=en"
      end
    end

    context "when location is correspondence" do
      let(:location) { "correspondence" }

      context "when lookup_used is false" do
        it "returns the manual address entry path" do
          expect(link).to eq "/providers/applications/#{legal_aid_application.id}/correspondence_address/enter_correspondence_address?locale=en#postcode"
        end
      end

      context "when lookup_used is true" do
        let(:lookup_used) { true }

        it "returns the address lookup path" do
          expect(link).to eq "/providers/applications/#{legal_aid_application.id}/correspondence_address/find_correspondence_address?locale=en#postcode"
        end
      end
    end
  end

  describe ".home_address_text" do
    subject(:text) { helper.home_address_text(applicant) }

    let(:address) { create(:address, location: "home") }

    context "when applicant has same home and correspondence address" do
      let(:same_correspondence_and_home_address) { true }

      it { expect(text).to eq "Same as correspondence address" }
    end

    context "when applicant has no fixed residence" do
      let(:no_fixed_residence) { true }

      it { expect(text).to eq "No fixed residence" }
    end

    context "when applicant has a home address" do
      it { expect(text).to eq "#{address.address_line_one}<br>#{address.address_line_two}<br>#{address.city}<br>#{address.county}<br>#{address.pretty_postcode}" }
    end
  end
end
