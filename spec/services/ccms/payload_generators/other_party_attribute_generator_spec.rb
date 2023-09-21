require "rails_helper"

module CCMS
  module PayloadGenerators
    RSpec.describe OtherPartyAttributeGenerator, :ccms do
      let(:namespaces) { CCMS::Requestors::BaseRequestor::NAMESPACES }
      let(:other_party_xpath) { "//casebio:OtherParties/casebio:OtherParty" }

      describe ".call" do
        subject(:call) do
          Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
            xml.__send__(:"soap:Envelope", namespaces) do
              xml.__send__(:"casebio:OtherParties") do
                described_class.call(xml, other_party)
              end
            end
          end
        end

        context "with an individual opponent" do
          let(:other_party) { create(:opponent, first_name: "Joffrey", last_name: "Boratheon") }

          before do
            allow(CCMS::OpponentId).to receive(:next_serial_id).and_return(99_123_456)
          end

          it "generates expected xml" do
            person_xpath = "#{other_party_xpath}/casebio:OtherPartyDetail/casebio:Person"

            expect(call)
              .to have_xml("#{other_party_xpath}/casebio:OtherPartyID", "OPPONENT_99123456")
              .and have_xml("#{other_party_xpath}/casebio:SharedInd", "false")
              .and have_xml("#{person_xpath}/casebio:Name/common:Title", "")
              .and have_xml("#{person_xpath}/casebio:Name/common:FirstName", "Joffrey")
              .and have_xml("#{person_xpath}/casebio:Name/common:Surname", "Boratheon")
              .and have_xml("#{person_xpath}/casebio:RelationToClient", "NONE")
              .and have_xml("#{person_xpath}/casebio:RelationToCase", "OPP")
          end
        end

        context "with an existing opponent organisation" do
          let(:other_party) do
            create(:opponent,
                   :for_organisation,
                   organisation_name: "Bucks Council",
                   organisation_ccms_type_code: "LA",
                   organisation_ccms_type_text: "Local Authority",
                   ccms_opponent_id: "222222",
                   exists_in_ccms: true)
          end

          it "generates expected xml" do
            organization_xpath = "#{other_party_xpath}/casebio:OtherPartyDetail/casebio:Organization"

            expect(call)
              .to have_xml("#{other_party_xpath}/casebio:OtherPartyID", "222222")
              .and have_xml("#{other_party_xpath}/casebio:SharedInd", "true")
              .and have_xml("#{organization_xpath}/casebio:OrganizationName", "Bucks Council")
              .and have_xml("#{organization_xpath}/casebio:OrganizationType", "LA")
              .and have_xml("#{organization_xpath}/casebio:RelationToClient", "NONE")
              .and have_xml("#{organization_xpath}/casebio:RelationToCase", "OPP")
          end
        end

        context "with a new opponent organisation" do
          let(:other_party) do
            create(:opponent,
                   :for_organisation,
                   organisation_name: "Foobar Council",
                   organisation_ccms_type_code: "LA",
                   organisation_ccms_type_text: "Local Authority",
                   ccms_opponent_id: "")
          end

          before do
            allow(CCMS::OpponentId).to receive(:next_serial_id).and_return(999_888)
          end

          it "generates expected xml" do
            organization_xpath = "#{other_party_xpath}/casebio:OtherPartyDetail/casebio:Organization"

            expect(call)
              .to have_xml("#{other_party_xpath}/casebio:OtherPartyID", "OPPONENT_999888")
              .and have_xml("#{other_party_xpath}/casebio:SharedInd", "false")
              .and have_xml("#{organization_xpath}/casebio:OrganizationName", "Foobar Council")
              .and have_xml("#{organization_xpath}/casebio:OrganizationType", "LA")
              .and have_xml("#{organization_xpath}/casebio:RelationToClient", "NONE")
              .and have_xml("#{organization_xpath}/casebio:RelationToCase", "OPP")
          end
        end

        context "with an involved child" do
          let(:other_party) { create(:involved_child, full_name: "Billy Elliot", date_of_birth: Date.new(2020, 1, 1)) }

          before do
            allow(CCMS::OpponentId).to receive(:next_serial_id).and_return(777_777)
          end

          it "generates expected xml" do
            person_xpath = "#{other_party_xpath}/casebio:OtherPartyDetail/casebio:Person"

            expect(call)
              .to have_xml("#{other_party_xpath}/casebio:OtherPartyID", "OPPONENT_777777")
              .and have_xml("#{other_party_xpath}/casebio:SharedInd", "false")
              .and have_xml("#{person_xpath}/casebio:Name/common:Title", "")
              .and have_xml("#{person_xpath}/casebio:Name/common:FirstName", "Billy")
              .and have_xml("#{person_xpath}/casebio:Name/common:Surname", "Elliot")
              .and have_xml("#{person_xpath}/casebio:DateOfBirth", "2020-01-01")
              .and have_xml("#{person_xpath}/casebio:RelationToClient", "UNKNOWN")
              .and have_xml("#{person_xpath}/casebio:RelationToCase", "CHILD")
          end
        end
      end
    end
  end
end
