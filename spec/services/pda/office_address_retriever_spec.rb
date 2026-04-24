require "rails_helper"
require Rails.root.join("spec/services/pda/provider_details_request_stubs")

RSpec.describe PDA::OfficeAddressRetriever do
  let(:office_code) { "4A497U" }

  describe "#call" do
    subject(:call) { described_class.new(office_code).call }

    context "when the API call is successful" do
      before do
        stub_provider_offices_address_for(office_code)
      end

      it "returns an OfficeAddressStruct with the expected data" do
        result = call

        expect(result)
          .to be_a(PDA::OfficeAddressStruct)

        expect(result).to have_attributes(
          code: office_code,
          firm_name: "Test firm",
          address_line_one: "Test address line 1",
          address_line_two: "Test address line 2",
          address_line_three: nil,
          address_line_four: nil,
          city: "Test city",
          county: nil,
          post_code: "TE5T1NG",
        )
      end
    end

    context "when the API call is successful but no address is found" do
      before do
        stub_provider_offices_address_failure_for(office_code, status: 204)
      end

      it "raises a NotFoundError" do
        expect { call }.to raise_error(described_class::NotFoundError)
      end

      it "logs the error and captures it in Sentry" do
        allow(Rails.logger).to receive(:error)
        allow(Sentry).to receive(:capture_message)

        begin
          call
        rescue StandardError
          nil
        end

        expect(Rails.logger).to have_received(:error).with(/Office address not found/)
        expect(Sentry).to have_received(:capture_message).with(/Office address not found/)
      end

      context "when the API call fails with an error" do
        before do
          stub_provider_offices_address_failure_for(office_code, status: 500)
        end

        it "raises an ApiError" do
          expect { call }.to raise_error(described_class::ApiError)
        end

        it "logs the error and captures it in Sentry" do
          allow(Rails.logger).to receive(:error)
          allow(Sentry).to receive(:capture_message)

          begin
            call
          rescue StandardError
            nil
          end

          expect(Rails.logger).to have_received(:error).with(/#{described_class} - .*office code #{office_code}.*API Call Failed.*500.*/)
          expect(Sentry).to have_received(:capture_message).with(/#{described_class} - API Call Failed.*500.*/)
        end
      end
    end
  end

  describe ".call" do
    subject(:call) { described_class.call(office_code) }

    context "when the API call is successful" do
      before do
        stub_provider_offices_address_for(office_code)
      end

      it "returns an OfficeAddressStruct, same as instance call" do
        expect(call)
          .to be_a(PDA::OfficeAddressStruct)
      end
    end
  end
end
