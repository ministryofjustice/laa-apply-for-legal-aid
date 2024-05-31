require "rails_helper"

RSpec.describe CheckProviderAnswersHelper do
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant, address:, same_correspondence_and_home_address:, no_fixed_residence:) }
  let(:same_correspondence_and_home_address) { false }
  let(:no_fixed_residence) { false }
  let(:lookup_used) { false }
  let(:address) { create(:address, lookup_used:) }

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
        it "returns the address choice path" do
          expect(link).to eq "/providers/applications/#{legal_aid_application.id}/correspondence_address/where_to_send_correspondence?locale=en#postcode"
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

    context "when applicant has no fixed residence" do
      let(:no_fixed_residence) { true }

      it { expect(text).to eq "No fixed residence" }
    end

    context "when applicant has a home address" do
      it { expect(text).to eq "#{address.address_line_one}<br>#{address.address_line_two}<br>#{address.city}<br>#{address.county}<br>#{address.pretty_postcode}" }
    end
  end

  describe ".correspondence_address_text" do
    subject(:text) { helper.correspondence_address_text(applicant) }

    context "when applicant has same home and correspondence address" do
      let(:address) { create(:address, location: "home") }
      let(:same_correspondence_and_home_address) { true }

      it { expect(text).to eq "#{address.address_line_one}<br>#{address.address_line_two}<br>#{address.city}<br>#{address.county}<br>#{address.pretty_postcode}" }
    end

    context "when applicant has a separate correspondence address" do
      let(:address) { create(:address, location: "correspondence") }
      let(:same_correspondence_and_home_address) { false }

      it { expect(text).to eq "#{address.address_line_one}<br>#{address.address_line_two}<br>#{address.city}<br>#{address.county}<br>#{address.pretty_postcode}" }
    end
  end
end
