require "rails_helper"

RSpec.describe BenefitCheckService do
  subject(:benefit_check_service) { described_class.new(application) }

  let(:last_name) { "WALKER" }
  let(:date_of_birth) { "1980/01/10".to_date }
  let(:national_insurance_number) { "JA293483A" }
  let(:applicant) { create(:applicant, last_name:, date_of_birth:, national_insurance_number:) }
  let(:application) { create(:application, applicant:) }
  let(:savon_client) { instance_double(Savon::Client) }

  describe "#check_benefits", :vcr do
    let(:expected_params) do
      hash_including(
        message: hash_including(
          clientReference: application.id,
          surname: applicant.last_name.strip.upcase,
          dateOfBirth: applicant.date_of_birth.strftime("%Y%m%d"),
        ),
      )
    end

    context "when the call is successful", vcr: { cassette_name: "benefit_check_service/successful_call" } do
      it "returns the right parameters" do
        result = benefit_check_service.call
        expect(result[:benefit_checker_status]).to eq("Yes")
        expect(result[:original_client_ref]).not_to be_empty
        expect(result[:confirmation_ref]).not_to be_empty
      end

      it "sends the right parameters" do
        allow(Savon).to receive(:client).and_return(savon_client)
        expect(savon_client).to receive(:call).with(:check, expected_params)
        benefit_check_service.call
      end

      context "when the last name is not in upper case" do
        let(:last_name) { " walker " }

        it "normalizes the last name" do
          result = benefit_check_service.call
          expect(result[:benefit_checker_status]).to eq("Yes")
        end

        it "sends the right parameters" do
          allow(Savon).to receive(:client).and_return(savon_client)
          expect(savon_client).to receive(:call).with(:check, expected_params)
          benefit_check_service.call
        end
      end
    end

    context "when calling the API raises a Savon::SOAPFault error", vcr: { cassette_name: "benefit_check_service/service_error" } do
      let(:last_name) { "SERVICEEXCEPTION" }

      it "captures error" do
        expect(AlertManager).to receive(:capture_exception).with(message_contains("Service unavailable"))
        benefit_check_service.call
      end

      it "returns false" do
        expect(benefit_check_service.call).to be false
      end
    end

    context "when calling the API raises an unhandled error or StandardError" do
      before do
        allow(Savon).to receive(:client).and_return(savon_client)
        allow(savon_client).to receive(:call)
                                 .with(:check, expected_params)
                                 .and_raise(StandardError.new("fake error"))
      end

      it "captures error" do
        expect(AlertManager).to receive(:capture_exception).with(message_contains("fake error"))
        benefit_check_service.call
      end

      it "captures StandardError" do
        expect(AlertManager).to receive(:capture_exception).with(instance_of(StandardError))
        benefit_check_service.call
      end

      it "returns false" do
        expect(benefit_check_service.call).to be false
      end
    end

    context "when the API times out" do
      before do
        allow(Savon).to receive(:client).and_return(savon_client)
        allow(savon_client).to receive(:call).and_raise(Net::ReadTimeout)
      end

      it "captures error and returns false" do
        expect(AlertManager).to receive(:capture_exception).with(Net::ReadTimeout)
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
        expect(AlertManager).to receive(:capture_exception).with(message_contains("Invalid request credentials"))
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
