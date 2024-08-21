require "rails_helper"

RSpec.describe CheckProviderAnswersHelper do
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { create(:applicant, address:, same_correspondence_and_home_address:, no_fixed_residence:, correspondence_address_choice:) }
  let(:same_correspondence_and_home_address) { false }
  let(:no_fixed_residence) { false }
  let(:lookup_used) { false }
  let(:correspondence_address_choice) { "home" }
  let(:address) { create(:address, lookup_used:) }

  describe ".change_address_link" do
    subject(:link) { helper.change_address_link(legal_aid_application) }

    let(:location) { "correspondence" }

    context "when mail is sent to office address" do
      let(:correspondence_address_choice) { "office" }

      it "returns the address choice path" do
        expect(link).to eq "/providers/applications/#{legal_aid_application.id}/correspondence_address/enter_correspondence_address?locale=en"
      end
    end

    context "when mail is not sent to office address" do
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
