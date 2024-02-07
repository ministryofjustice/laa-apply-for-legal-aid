module CCMS
  module Requestors
    class ApplicantSearchRequestor < BaseRequestor
      wsdl_from Rails.configuration.x.ccms_soa.clientProxyServiceWsdl

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
        xml.__send__(:"clientbim:ClientInqRQ") do
          xml.__send__(:"hdr:HeaderRQ") { ns3_header_rq(xml, @provider_username) }
          xml.__send__(:"clientbim:RecordCount") { record_count(xml) }
          xml.__send__(:"clientbim:SearchCriteria") { search_criteria(xml) }
        end
      end

      def record_count(xml)
        xml.__send__(:"common:MaxRecordsToFetch", 200)
        xml.__send__(:"common:RetriveDataOnMaxCount", false)
      end

      def search_criteria(xml)
        xml.__send__(:"clientbim:ClientInfo") do
          xml.__send__(:"clientbio:FirstName", @applicant.first_name)
          xml.__send__(:"clientbio:Surname", @applicant.surname_at_birth)
          xml.__send__(:"clientbio:DateOfBirth", @applicant.date_of_birth.to_fs(:ccms_date))
          xml.__send__(:"clientbio:NINumber", @applicant.national_insurance_number)
        end
      end
    end
  end
end
