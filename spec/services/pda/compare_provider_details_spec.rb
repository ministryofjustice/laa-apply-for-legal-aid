require "rails_helper"
require_relative "provider_details_request_stubs"

RSpec.describe PDA::CompareProviderDetails do
  describe ".call" do
    subject(:call) { described_class.call(provider.id) }

    before do
      allow(Rails.logger).to receive(:info).at_least(:once)
      firm.providers << provider
      provider.offices += offices
    end

    let(:firm) { create(:firm, ccms_id: ccms_firm_id, name: firm_name) }
    let(:ccms_firm_id) { 99_999 }
    let(:firm_name) { "Test firm" }

    let(:provider) { create(:provider, username: "test-user", contact_id: 494_000) }
    let(:contact_id) { 494_000 }

    let(:offices) do
      [
        create(:office, ccms_id: 111_111, code: "1A111B"),
        create(:office, ccms_id: 222_222, code: "2A222B"),
      ]
    end

    context "when old PDA returns details that match the new PDA provider's details" do
      before do
        stub_provider_offices
        stub_provider_firm_offices
      end

      it "logs start and end time" do
        call
        expect(Rails.logger)
          .to have_received(:info)
          .with(%r{PDA::CompareProviderDetails:: start: .* end: .* duration: .* seconds})
      end

      it "logs that the details match" do
        call
        expect(Rails.logger)
          .to have_received(:info)
          .with("PDA::CompareProviderDetails:: Provider #{provider.id} results match.")
      end
    end

    context "when old PDA returns details that do NOT match the new PDA provider's details" do
      before do
        stub_provider_offices
        stub_provider_firm_offices
      end

      context "when users firm.ccms_id does not match" do
        let(:ccms_firm_id) { 99_888 }

        it "logs that the details do not match" do
          call
          expect(Rails.logger)
            .to have_received(:info)
            .with("PDA::CompareProviderDetails:: Provider #{provider.id} 99999 does not match firm.ccms_id #{ccms_firm_id}")
        end
      end

      context "when the firm.name does not match" do
        let(:firm_name) { "Wrong firm name" }

        it "logs that the details do not match" do
          call
          expect(Rails.logger)
            .to have_received(:info)
            .with("PDA::CompareProviderDetails:: Provider #{provider.id} \"Test firm\" does not match firm.name \"#{firm.name}\"")
        end
      end

      context "when the contact_id does not match" do
        before { provider.update!(contact_id: 105) }

        it "logs that the details do not match" do
          call
          expect(Rails.logger)
            .to have_received(:info)
            .with("PDA::CompareProviderDetails:: Provider #{provider.id} #{contact_id} does not match provider.contact_id #{provider.contact_id}")
        end
      end

      context "when no office codes match" do
        let(:offices) do
          [create(:office, ccms_id: 333_333, code: "2A222B")]
        end

        it "logs that the details do not match" do
          call
          expect(Rails.logger)
            .to have_received(:info)
            .with("PDA::CompareProviderDetails:: Provider #{provider.id} [\"111111 1A111B\", \"222222 2A222B\"] does not match [\"333333 2A222B\"]")
        end
      end

      context "when an office returned by PDA does not exist in apply" do
        before do
          provider.offices.find_by(ccms_id: 222_222).destroy!
        end

        it "logs that the details do not match" do
          call
          expect(Rails.logger)
            .to have_received(:info)
            .with("PDA::CompareProviderDetails:: Provider #{provider.id} [\"111111 1A111B\", \"222222 2A222B\"] does not match [\"111111 1A111B\"]")
        end
      end

      context "when an office is missing from the PDA response" do
        let(:additional_office) { create(:office, ccms_id: 333_333, code: "2A222B") }

        before do
          provider.offices << additional_office
        end

        it "logs that the details do not match" do
          call
          expect(Rails.logger)
            .to have_received(:info)
            .with("PDA::CompareProviderDetails:: Provider #{provider.id} [\"111111 1A111B\", \"222222 2A222B\"] does not match [\"111111 1A111B\", \"222222 2A222B\", \"333333 2A222B\"]")
        end
      end
    end

    context "when PDA returns an empty response" do
      before do
        stub_provider_details_retriever_record_not_found(
          provider:,
        )
      end

      it "logs that the details do not match" do
        call
        expect(Rails.logger)
          .to have_received(:info)
          .with("PDA::CompareProviderDetails:: User not found for #{provider.id}.")
      end
    end

    context "when PDA returns an error" do
      before do
        stub_provider_details_retriever_api_error(
          provider:,
        )
      end

      it "logs that the details do not match" do
        call
        expect(Rails.logger)
          .to have_received(:info)
          .with(/PDA::CompareProviderDetails:: User #{provider.id} API Call Failed/)
      end
    end
  end
end
