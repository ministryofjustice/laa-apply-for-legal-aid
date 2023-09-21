module CCMS
  module PayloadGenerators
    class OtherPartyAttributeGenerator
      attr_accessor :xml, :other_party

      def initialize(xml, other_party)
        @xml = xml
        @other_party = other_party
      end

      def self.call(xml, other_party)
        new(xml, other_party).call
      end

      def call
        if other_party.ccms_child?
          append_involved_child
        elsif other_party.individual?
          append_opponent_individual
        elsif other_party.organisation?
          append_opponent_organisation
        end
      end

    private

      def append_opponent_individual
        xml.__send__(:"casebio:OtherParty") do
          xml.__send__(:"casebio:OtherPartyID", "OPPONENT_#{other_party.generate_ccms_opponent_id}")
          xml.__send__(:"casebio:SharedInd", false)
          xml.__send__(:"casebio:OtherPartyDetail") do
            xml.__send__(:"casebio:Person") do
              xml.__send__(:"casebio:Name") do
                xml.__send__(:"common:Title", "")
                xml.__send__(:"common:Surname", other_party.last_name)
                xml.__send__(:"common:FirstName", other_party.first_name)
              end
              xml.__send__(:"casebio:Address")
              xml.__send__(:"casebio:RelationToClient", "NONE")
              xml.__send__(:"casebio:RelationToCase", "OPP")
              xml.__send__(:"casebio:ContactDetails")
            end
          end
        end
      end

      def append_opponent_organisation
        if other_party.exists_in_ccms?
          append_opponent_existing_organisation
        else
          append_opponent_new_organisation
        end
      end

      def append_opponent_new_organisation
        xml.__send__(:"casebio:OtherParty") do
          xml.__send__(:"casebio:OtherPartyID", "OPPONENT_#{other_party.generate_ccms_opponent_id}")
          xml.__send__(:"casebio:SharedInd", false)
          xml.__send__(:"casebio:OtherPartyDetail") do
            xml.__send__(:"casebio:Organization") do
              xml.__send__(:"casebio:OrganizationName", other_party.full_name)
              xml.__send__(:"casebio:OrganizationType", other_party.ccms_type_code)
              xml.__send__(:"casebio:RelationToClient", "NONE")
              xml.__send__(:"casebio:RelationToCase", "OPP")
              xml.__send__(:"casebio:Address")
              xml.__send__(:"casebio:ContactDetails")
            end
          end
        end
      end

      def append_opponent_existing_organisation
        xml.__send__(:"casebio:OtherParty") do
          xml.__send__(:"casebio:OtherPartyID", other_party.ccms_opponent_id)
          xml.__send__(:"casebio:SharedInd", true)
          xml.__send__(:"casebio:OtherPartyDetail") do
            xml.__send__(:"casebio:Organization") do
              xml.__send__(:"casebio:OrganizationName", other_party.full_name)
              xml.__send__(:"casebio:OrganizationType", other_party.ccms_type_code)
              xml.__send__(:"casebio:Address")
              xml.__send__(:"casebio:RelationToClient", "NONE")
              xml.__send__(:"casebio:RelationToCase", "OPP")
              xml.__send__(:"casebio:ContactName", "Not Available")
            end
          end
        end
      end

      def append_involved_child
        first_name, last_name = other_party.split_full_name
        xml.__send__(:"casebio:OtherParty") do
          xml.__send__(:"casebio:OtherPartyID", "OPPONENT_#{other_party.generate_ccms_opponent_id}")
          xml.__send__(:"casebio:SharedInd", false)
          xml.__send__(:"casebio:OtherPartyDetail") do
            xml.__send__(:"casebio:Person") do
              xml.__send__(:"casebio:Name") do
                xml.__send__(:"common:Title", "")
                xml.__send__(:"common:Surname", last_name)
                xml.__send__(:"common:FirstName", first_name)
              end
              xml.__send__(:"casebio:DateOfBirth", other_party.date_of_birth.strftime("%F"))
              xml.__send__(:"casebio:Address")
              xml.__send__(:"casebio:RelationToClient", "UNKNOWN")
              xml.__send__(:"casebio:RelationToCase", "CHILD")
              xml.__send__(:"casebio:ContactDetails")
            end
          end
        end
      end
    end
  end
end
