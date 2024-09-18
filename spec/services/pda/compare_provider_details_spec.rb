require "rails_helper"

RSpec.describe PDA::CompareProviderDetails do
  let(:firm_struct) { Struct.new(:id, :name) }
  let(:office_struct) { Struct.new(:id, :code) }
  let(:provider_details_struct) { Struct.new(:firm_id, :contact_id, :firm_name, :offices) }

  describe ".call" do
    subject(:call) { described_class.call(provider.id) }

    before do
      allow(Rails.logger).to receive(:info).at_least(:once)
      firm.providers << provider
      provider.offices << office
    end

    let(:provider) { create(:provider, username:, contact_id:) }
    let(:firm) { create(:firm, ccms_id: ccms_firm_id, name: firm_name) }
    let(:office) { create(:office, ccms_id: ccms_office_id, code: office_code) }
    let(:firm_name) { "Test Firm" }
    let(:office_code) { "6D456C" }
    let(:username) { "test-user" }
    let(:ccms_firm_id) { "1" }
    let(:ccms_office_id) { "2" }
    let(:contact_id) { 104 }
    let(:ccms_firm) { firm_struct.new(ccms_firm_id, firm_name) }
    let(:ccms_office) { office_struct.new(ccms_office_id, office_code) }

    context "when PDA returns details that match the provider's details" do
      before do
        stub_provider_details_retriever(
          provider:,
          contact_id:,
          firm: ccms_firm,
          offices: [ccms_office],
        )
      end

      it "logs that the details match" do
        expect(Rails.logger).to receive(:info).with("PDA::CompareProviderDetails:: Provider #{provider.id} results match.")
        call
      end
    end

    context "when PDA returns details that do not match the provider's details" do
      before do
        stub_provider_details_retriever(
          provider:,
          contact_id:,
          firm: ccms_firm,
          offices: [ccms_office],
        )
      end

      context "when the firm.ccms_id does not match" do
        let(:ccms_firm) { firm_struct.new(3, firm_name) }

        it "logs that the details do not match" do
          expect(Rails.logger).to receive(:info).with("PDA::CompareProviderDetails:: Provider #{provider.id} #{ccms_firm.id} does not match firm.ccms_id #{firm.ccms_id}")
          call
        end
      end

      context "when the firm.name does not match" do
        let(:ccms_firm) { firm_struct.new(ccms_firm_id, "Wrong firm name") }

        it "logs that the details do not match" do
          expect(Rails.logger).to receive(:info).with("PDA::CompareProviderDetails:: Provider #{provider.id} #{ccms_firm.name} does not match firm.name #{firm.name}")
          call
        end
      end

      context "when the contact_id does not match" do
        before { provider.update!(contact_id: 105) }

        it "logs that the details do not match" do
          expect(Rails.logger).to receive(:info).with("PDA::CompareProviderDetails:: Provider #{provider.id} #{contact_id} does not match provider.contact_id #{provider.contact_id}")
          call
        end
      end

      context "when the office details do not match" do
        context "when the office codes do not match" do
          let(:ccms_office) { office_struct.new(ccms_office_id, "9R678Y") }

          it "logs that the details do not match" do
            expect(Rails.logger).to receive(:info).with("PDA::CompareProviderDetails:: Provider #{provider.id} [\"#{ccms_office.id} #{ccms_office.code}\"] does not match [\"#{office.ccms_id} #{office.code}\"]")
            call
          end
        end

        context "when the office returned by PDA does not exist in apply" do
          let(:ccms_office) { office_struct.new(3, office_code) }

          it "logs that the details do not match" do
            expect(Rails.logger).to receive(:info).with("PDA::CompareProviderDetails:: Provider #{provider.id} [\"#{ccms_office.id} #{ccms_office.code}\"] does not match [\"#{office.ccms_id} #{office.code}\"]")
            call
          end
        end

        context "when an office is missing from the PDA response" do
          let(:additional_office) { create(:office, ccms_id: "3", code: "4C880Q") }

          it "logs that the details do not match" do
            provider.offices << additional_office
            expect(Rails.logger).to receive(:info).with("PDA::CompareProviderDetails:: Provider #{provider.id} [\"#{ccms_office.id} #{ccms_office.code}\"] does not match [\"#{office.ccms_id} #{office.code}\", \"#{additional_office.ccms_id} #{additional_office.code}\"]")
            call
          end
        end
      end
    end

    context "when provider_details_retriever raises an error" do
      context "when PDA returns an empty response" do
        before do
          stub_provider_details_retriever_record_not_found(
            provider:,
          )
        end

        it "logs that the details do not match" do
          expect(Rails.logger).to receive(:info).with("PDA::CompareProviderDetails:: User not found for #{provider.id}.")
          call
        end
      end

      context "when PDA returns an error" do
        before do
          stub_provider_details_retriever_api_error(
            provider:,
          )
        end

        it "logs that the details do not match" do
          expect(Rails.logger).to receive(:info).with("PDA::CompareProviderDetails:: User #{provider.id} PDA::ProviderDetailsRetriever::ApiError")
          call
        end
      end
    end
  end

  def stub_provider_details_retriever(provider:, firm:, offices:, contact_id:)
    allow(PDA::ProviderDetailsRetriever)
      .to receive(:call)
      .with(provider.username)
      .and_return(api_response(firm:, offices:, contact_id:))
  end

  def stub_provider_details_retriever_record_not_found(provider:)
    allow(PDA::ProviderDetailsRetriever)
      .to receive(:call)
      .with(provider.username)
      .and_raise(PDA::ProviderDetailsRetriever::ApiRecordNotFoundError)
  end

  def stub_provider_details_retriever_api_error(provider:)
    allow(PDA::ProviderDetailsRetriever)
      .to receive(:call)
      .with(provider.username)
      .and_raise(PDA::ProviderDetailsRetriever::ApiError)
  end

  def api_response(firm:, offices:, contact_id:)
    provider_details_struct.new(firm_id: firm.id, contact_id:, firm_name: firm.name, offices:)
  end
end
