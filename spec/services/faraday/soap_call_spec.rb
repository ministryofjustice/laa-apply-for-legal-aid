require "rails_helper"

RSpec.describe Faraday::SoapCall do
  subject(:faraday_soap_call) { described_class.new(initial_object, type) }

  let(:type) { :ccms }

  describe "initializing" do
    describe "with a bad attribute" do
      let(:initial_object) { "clearly not a url" }

      it "raises an error" do
        expect { faraday_soap_call }.to raise_error("Unable to parse url")
      end
    end

    describe "with a url" do
      let(:initial_object) { "https://fake/wsdl/url" }
      let(:type) { :benefit_checker }

      it { expect(faraday_soap_call.url).to eql("https://fake/wsdl/url") }
    end

    describe "with a wsdl file" do
      let(:initial_object) { Rails.root.join("app/services/ccms/wsdls/", Rails.configuration.x.ccms_soa.getReferenceDataWsdl).to_s }
      let(:expected) { "https://ccms-soa-managed.laa-test.modernisation-platform.service.justice.gov.uk/soa-infra/services/default/GetReferenceData/getreferencedata_ep" }

      it { expect(faraday_soap_call.url).to eql(expected) }
    end
  end

  describe ".headers" do
    subject(:headers) { faraday_soap_call.headers }

    let(:initial_object) { "https://fake/wsdl/url" }

    context "when setting type as ccms" do
      let(:type) { :ccms }
      let(:expected) do
        {
          SOAPAction: "#POST",
          "Content-Type": "text/xml",
          "x-api-key": Rails.configuration.x.ccms_soa.aws_gateway_api_key,
        }
      end

      it { expect(headers).to eql(expected) }
    end

    context "when setting type as benefit_checker" do
      let(:type) { :benefit_checker }
      let(:expected) do
        {
          SOAPAction: "#POST",
          "Content-Type": "text/xml",
        }
      end

      it { expect(headers).to eql(expected) }
    end
  end

  describe ".call", vcr: { cassette_name: "benefit_check_service/successful_call" } do
    let(:calling) { faraday_soap_call.call(payload) }
    let(:type) { :benefit_checker }
    let(:initial_object) { Rails.configuration.x.benefit_check.wsdl_url }
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
        <lscServiceName>#{Rails.configuration.x.benefit_check.service_name}</lscServiceName>
        <clientOrgId>#{Rails.configuration.x.benefit_check.client_org_id}</clientOrgId>
        <clientUserId>#{Rails.configuration.x.benefit_check.client_user_id}</clientUserId>
        </wsdl:check></env:Body></env:Envelope>
      PAYLOAD
    end
    let(:expected) do
      <<~XML.squish
        <?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><benefitCheckerResponse
        xmlns="https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"><ns1:originalClientRef
        xmlns:ns1="http://lsc.gov.uk/benefitchecker/data/1.0">df56670b-aecf-49cc-8f1b-1c410cace3c5</ns1:originalClientRef><ns2:benefitCheckerStatus
        xmlns:ns2="http://lsc.gov.uk/benefitchecker/data/1.0">Yes</ns2:benefitCheckerStatus><ns3:confirmationRef
        xmlns:ns3="http://lsc.gov.uk/benefitchecker/data/1.0">T1765875076825</ns3:confirmationRef></benefitCheckerResponse></soapenv:Body></soapenv:Envelope>
      XML
    end

    it "returns expected xml body" do
      expect(calling).to eql(expected)
    end

    context "when there is a connection error" do
      let(:expected_message) { "my faraday connection failed" }

      it "creates a CFE::Submission error and writes a history record with a backtrace" do
        stub_request(:post, initial_object).to_raise(Faraday::ConnectionFailed.new(expected_message))
        expect(AlertManager).to receive(:capture_exception).with(message_contains(expected_message))
        expect(Rails.logger).to receive(:error).with(expected_message)
        expect { calling }.to raise_error Faraday::SoapError, expected_message
      end
    end
  end
end
