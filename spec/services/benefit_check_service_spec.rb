require "rails_helper"

RSpec.describe BenefitCheckService do
  subject(:benefit_check_service) { described_class.new(application) }

  before do
    allow(Rails.configuration.x.benefit_check).to receive_messages(service_name: Rails.configuration.x.benefit_check.wsdl_url, client_org_id: "dummy_client_org_id", client_user_id: "dummy_client_user_id")
  end

  let(:last_name) { "WALKER" }
  let(:date_of_birth) { "1980/01/10".to_date }
  let(:national_insurance_number) { "JA293483A" }
  let(:applicant) { create(:applicant, last_name:, date_of_birth:, national_insurance_number:) }
  let(:application) { create(:application, applicant:) }
  let(:faraday) { instance_double(Faraday::SoapCall) }

  describe "#call", :vcr do
    let(:payload) do
      <<~PAYLOAD.squish
        <?xml version="1.0" encoding="UTF-8"?>#{' '}
        <env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:wsdl="https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
        <env:Body> <wsdl:check>
        <wsdl:clientReference>#{application.id}</wsdl:clientReference>
        <wsdl:nino>JA293483A</wsdl:nino>
        <wsdl:surname>WALKER</wsdl:surname>
        <wsdl:dateOfBirth>19800110</wsdl:dateOfBirth>
        <wsdl:dateOfAward>#{application.created_at.strftime('%Y%m%d')}</wsdl:dateOfAward>
        <wsdl:lscServiceName>#{Rails.configuration.x.benefit_check.service_name}</wsdl:lscServiceName>
        <wsdl:clientOrgId>#{Rails.configuration.x.benefit_check.client_org_id}</wsdl:clientOrgId>
        <wsdl:clientUserId>#{Rails.configuration.x.benefit_check.client_user_id}</wsdl:clientUserId>
        </wsdl:check> </env:Body> </env:Envelope>
      PAYLOAD
    end

    let(:response) do
      <<~XML.squish
        <?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><benefitCheckerResponse
        xmlns="https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"><ns1:originalClientRef
        xmlns:ns1="http://lsc.gov.uk/benefitchecker/data/1.0">#{application.id}</ns1:originalClientRef><ns2:benefitCheckerStatus
        xmlns:ns2="http://lsc.gov.uk/benefitchecker/data/1.0">Yes</ns2:benefitCheckerStatus><ns3:confirmationRef
        xmlns:ns3="http://lsc.gov.uk/benefitchecker/data/1.0">T1658229558145</ns3:confirmationRef></benefitCheckerResponse></soapenv:Body></soapenv:Envelope>
      XML
    end

    context "when the call is successful" do
      before do
        allow(Faraday::SoapCall).to receive(:new).and_return(faraday)
        allow(faraday).to receive(:call).with(payload).and_return(response)
      end

      it "returns the right parameters" do
        result = benefit_check_service.call
        expect(result[:benefit_checker_status]).to eq("Yes")
        expect(result[:original_client_ref]).not_to be_empty
        expect(result[:confirmation_ref]).not_to be_empty
      end

      it "sends the right parameters" do
        benefit_check_service.call
        expect(faraday).to have_received(:call).with(payload)
      end

      context "when the last name is not in upper case" do
        let(:last_name) { " walker " }

        it "normalizes the last name" do
          result = benefit_check_service.call
          expect(result[:benefit_checker_status]).to eq("Yes")
        end

        it "sends the right parameters" do
          allow(Faraday::SoapCall).to receive(:new).and_return(faraday)
          allow(faraday).to receive(:call).with(payload).and_return(response)
          benefit_check_service.call
          expect(faraday).to have_received(:call).with(payload)
        end
      end
    end

    context "when calling the API raises a Faraday::ConnectionFailed error" do
      before { stub_request(:post, Rails.configuration.x.benefit_check.wsdl_url).to_raise(Faraday::ConnectionFailed.new("Service unavailable")) }

      it "captures error" do
        expect(AlertManager).to receive(:capture_exception).with(message_contains("Service unavailable"))
        benefit_check_service.call
      end

      it "returns false" do
        expect(benefit_check_service.call).to be false
      end
    end

    context "when calling the API raises a StandardError" do
      before { stub_request(:post, Rails.configuration.x.benefit_check.wsdl_url).to_raise(StandardError.new("Fake error")) }

      it "captures error" do
        expect(AlertManager).to receive(:capture_exception).with(message_contains("Fake error"))
        benefit_check_service.call
      end

      it "returns false" do
        expect(benefit_check_service.call).to be false
      end
    end

    context "when the API times out" do
      before { stub_request(:post, Rails.configuration.x.benefit_check.wsdl_url).to_raise(Net::ReadTimeout) }

      it "captures error and returns false" do
        expect(AlertManager).to receive(:capture_exception).with(Faraday::TimeoutError)
        benefit_check_service.call
      end

      it "returns false" do
        expect(benefit_check_service.call).to be false
      end
    end

    context "when some credentials are missing", vcr: { cassette_name: "benefit_check_service/missing_credential" } do
      before do
        allow(Rails.configuration.x.benefit_check).to receive(:client_org_id).and_return("")
      end

      it "captures error" do
        expect(AlertManager).to receive(:capture_exception).with(message_contains("BenefitCheckError: Invalid request credentials."))
        benefit_check_service.call
      end

      it "returns false" do
        expect(benefit_check_service.call).to be false
      end
    end
  end

  describe ".call" do
    describe "behaviour without mock" do
      before do
        stub_const("BenefitCheckService::USE_MOCK", false)
      end

      it "calls an instance call method" do
        expect(described_class.call(application)).to be false
      end
    end

    describe "behaviour with mock" do
      before { stub_const("BenefitCheckService::USE_MOCK", true) }

      it "returns the right parameters" do
        result = described_class.call(application)
        expect(result[:benefit_checker_status]).to eq("Yes")
        expect(result[:confirmation_ref]).to match("mocked:")
      end

      context "with matching data" do
        let(:date_of_birth) { "1955/01/11".to_date }
        let(:national_insurance_number) { "ZZ123456A" }

        it "returns true" do
          result = described_class.call(application)
          expect(result[:benefit_checker_status]).to eq("No")
          expect(result[:confirmation_ref]).to match("mocked:")
        end
      end
    end
  end
end
