module CCMS
  module Requestors
    class ApplicantAddRequestor < BaseRequestor
      wsdl_from Rails.configuration.x.ccms_soa.clientProxyServiceWsdl

      attr_reader :applicant

      delegate :home_address_for_ccms, to: :applicant

      def initialize(applicant, provider_username)
        super()
        @applicant = applicant
        @provider_username = provider_username
      end

      def call
        Faraday::SoapCall.new(wsdl_location, :ccms).call(request_xml)
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
        xml.__send__(:"clientbio:NoFixedAbode", applicant.no_fixed_residence || false)
        xml.__send__(:"clientbio:Address") { applicant_address(xml) unless applicant.no_fixed_residence }
        xml.__send__(:"clientbio:EthnicMonitoring", 0)
      end

      def name(xml)
        xml.__send__(:"common:Surname", applicant.last_name)
        xml.__send__(:"common:FirstName", applicant.first_name)
        xml.__send__(:"common:SurnameAtBirth", applicant.surname_at_birth.presence)
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
        xml.__send__(:"common:AddressLine1", home_address_for_ccms.address_line_one)
        xml.__send__(:"common:AddressLine2", home_address_for_ccms.address_line_two)
        xml.__send__(:"common:City", home_address_for_ccms.city)
        xml.__send__(:"common:County", home_address_for_ccms.county)
        xml.__send__(:"common:Country", home_address_for_ccms.country)
        xml.__send__(:"common:PostalCode", home_address_for_ccms.pretty_postcode) if home_address_for_ccms.postcode.present?
      end
    end
  end
end
