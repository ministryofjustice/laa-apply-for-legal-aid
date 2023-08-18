module CCMS
  module Requestors
    class OpponentOrganisationSearchRequestor < BaseRequestor
      wsdl_from Rails.configuration.x.ccms_soa.getCommonOrgServiceWsdl

      def initialize(provider_username, organisation_name = nil, organisation_type = nil)
        super()
        @provider_username = provider_username
        @organisation_name = organisation_name
        @organisation_type = organisation_type
      end

      def call
        soap_client.call(:process, xml: request_xml)
      end

    private

      def request_xml
        soap_envelope(namespaces).to_xml
      end

      def soap_body(xml)
        xml.__send__(:"refdatabim:CommonOrgInqRQ") do
          xml.__send__(:"hdr:HeaderRQ") { ns3_header_rq(xml, @provider_username) }
          xml.__send__(:"refdatabim:RecordCount") { record_count(xml) }
          xml.__send__(:"refdatabim:SearchCriteria") { search_criteria(xml) }
        end
      end

      def record_count(xml)
        xml.__send__(:"common:MaxRecordsToFetch", 2000)
        xml.__send__(:"common:RetriveDataOnMaxCount", true)
      end

      def search_criteria(xml)
        xml.__send__(:"refdatabim:Organization") do
          xml.__send__(:"refdatabim:OrganizationName", @organisation_name)
          xml.__send__(:"refdatabim:OrganizationType", @organisation_type)
        end
      end
    end
  end
end
