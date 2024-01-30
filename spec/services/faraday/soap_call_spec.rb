require "rails_helper"

RSpec.describe Faraday::SoapCall do
  subject(:faraday_soap_call) { described_class.new(initial_object) }

  describe "initializing" do
    describe "with a bad attribute" do
      let(:initial_object) { "clearly not a url" }

      it "raises an error" do
        expect { faraday_soap_call }.to raise_error("Unable to parse url")
      end
    end

    describe "with a url" do
      let(:initial_object) { "https://fake/wsdl/url" }

      it { expect(faraday_soap_call.url).to eql("https://fake/wsdl/url") }
    end

    describe "with a wsdl file" do
      let(:initial_object) { Rails.root.join("app/services/ccms/wsdls/", Rails.configuration.x.ccms_soa.getReferenceDataWsdl).to_s }
      let(:expected) { "https://ccmssoagateway.dev.legalservices.gov.uk/ccmssoa/soa-infra/services/default/GetReferenceData!1.5*soa_92fe5600-6b1b-4d91-a97f-36e3955ae196/getreferencedata_ep" }

      it { expect(faraday_soap_call.url).to eql(expected) }
    end
  end

  describe ".call", vcr: { cassette_name: "benefit_check_service/savon_successful_call" } do
    let(:calling) { faraday_soap_call.call(payload) }
    let(:initial_object) { "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check" }
    let(:payload) do
      <<~PAYLOAD.squish
        <?xml version="1.0" encoding="UTF-8"?><env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:wsdl="https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"
        xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
        <env:Body><wsdl:check>
        <clientReference>df56670b-aecf-49cc-8f1b-1c410cace3c5</clientReference>
        <nino>JA293483A</nino>
        <surname>WALKER</surname>
        <dateOfBirth>19800110</dateOfBirth>
        <dateOfAward>20220719</dateOfAward>
        <lscServiceName><BC_LSC_SERVICE_NAME></lscServiceName><clientOrgId><BC_CLIENT_ORG_ID></clientOrgId><clientUserId><BC_CLIENT_USER_ID></clientUserId></wsdl:check></env:Body></env:Envelope>
      PAYLOAD
    end
    let(:expected) do
      <<~XML.squish
        <?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><benefitCheckerResponse
        xmlns="https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"><ns1:originalClientRef
        xmlns:ns1="http://lsc.gov.uk/benefitchecker/data/1.0">df56670b-aecf-49cc-8f1b-1c410cace3c5</ns1:originalClientRef><ns2:benefitCheckerStatus
        xmlns:ns2="http://lsc.gov.uk/benefitchecker/data/1.0">Yes</ns2:benefitCheckerStatus><ns3:confirmationRef
        xmlns:ns3="http://lsc.gov.uk/benefitchecker/data/1.0">T1658229558145</ns3:confirmationRef></benefitCheckerResponse></soapenv:Body></soapenv:Envelope>
      XML
    end

    it "returns expected xml body" do
      expect(calling).to eql(expected)
    end
  end
end
