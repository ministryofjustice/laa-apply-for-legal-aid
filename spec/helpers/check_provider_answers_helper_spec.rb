require "rails_helper"

RSpec.describe CheckProviderAnswersHelper do
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant, address:, same_correspondence_and_home_address:, no_fixed_residence:, correspondence_address_choice:) }
  let(:same_correspondence_and_home_address) { false }
  let(:no_fixed_residence) { false }
  let(:lookup_used) { false }
  let(:correspondence_address_choice) { "home" }
  let(:address) { create(:address, lookup_used:) }

  describe ".correspondence_address_change_link" do
    subject(:link) { helper.correspondence_address_change_link(legal_aid_application) }

    let(:location) { "correspondence" }

    context "when mail is to be sent to home address" do
      let(:correspondence_address_choice) { "home" }

      it "returns no link" do
        expect(link).to be_nil
      end
    end

    context "when mail is to be sent to office address" do
      let(:correspondence_address_choice) { "office" }

      it "returns the address choice path" do
        expect(link).to eq "/providers/applications/#{legal_aid_application.id}/correspondence_address/enter_correspondence_address?locale=en"
      end
    end

    context "when mail is to be sent to another uk residential address" do
      let(:correspondence_address_choice) { "residence" }

      it "returns the address choice path" do
        expect(link).to eq "/providers/applications/#{legal_aid_application.id}/correspondence_address/find_correspondence_address?locale=en"
      end
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
