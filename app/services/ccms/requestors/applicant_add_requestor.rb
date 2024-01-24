module CCMS
  module Requestors
    class ApplicantAddRequestor < BaseRequestor
      wsdl_from Rails.configuration.x.ccms_soa.clientProxyServiceWsdl

      attr_reader :applicant

      delegate :address, to: :applicant

      def initialize(applicant, provider_username)
        super()
        @applicant = applicant
        @provider_username = provider_username
      end

      def call
        make_faraday_request
      end

    private

      def request_xml
        soap_envelope(namespaces).to_xml
      end

      def soap_body(xml)
        xml.__send__(:"clientbim:ClientAddRQ") do
          xml.__send__(:"hdr:HeaderRQ") { ns3_header_rq(xml, @provider_username) }
          xml.__send__(:"clientbim:Client") { client(xml) }
        end
      end

      def client(xml)
        xml.__send__(:"clientbio:Name") { name(xml) }
        xml.__send__(:"clientbio:PersonalInformation") { personal_information(xml) }
        xml.__send__(:"clientbio:Contacts") { contacts(xml) }
        xml.__send__(:"clientbio:NoFixedAbode", false)
        xml.__send__(:"clientbio:Address") { applicant_address(xml) }
        xml.__send__(:"clientbio:EthnicMonitoring", 0)
      end

      def name(xml)
        xml.__send__(:"common:Surname", applicant.last_name)
        xml.__send__(:"common:FirstName", applicant.first_name)
      end

      # this is all mandatory: we don't hold any of this data except date of birth
      def personal_information(xml)
        xml.__send__(:"clientbio:DateOfBirth", applicant.date_of_birth.to_fs(:ccms_date))
        xml.__send__(:"clientbio:NINumber", applicant.national_insurance_number)
        xml.__send__(:"clientbio:Gender", "UNSPECIFIED")
        xml.__send__(:"clientbio:MaritalStatus", "U")
        xml.__send__(:"clientbio:VulnerableClient", false)
        xml.__send__(:"clientbio:HighProfileClient", false)
        xml.__send__(:"clientbio:VexatiousLitigant", false)
        xml.__send__(:"clientbio:CountryOfOrigin", "GBR")
        xml.__send__(:"clientbio:MentalCapacityInd", false)
      end

      # this is the only mandatory item of contact data. i'm not sure what it's for...
      def contacts(xml)
        xml.__send__(:"clientbio:Password", "Testing")
      end

      def applicant_address(xml)
        xml.__send__(:"common:AddressLine1", address.address_line_one)
        xml.__send__(:"common:AddressLine2", address.address_line_two)
        xml.__send__(:"common:City", address.city)
        xml.__send__(:"common:County", address.county)
        xml.__send__(:"common:Country", "GBR")
        xml.__send__(:"common:PostalCode", address.pretty_postcode)
      end
    end
  end
end
