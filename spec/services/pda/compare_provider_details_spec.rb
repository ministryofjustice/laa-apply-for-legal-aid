require "rails_helper"

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

    let(:provider) { create(:provider, contact_id: 494_000) }
    let(:contact_id) { 494_000 }

    let(:offices) do
      [
        create(:office, ccms_id: 111_111, code: "0A000B"),
        create(:office, ccms_id: 222_222, code: "1A111B"),
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
            .with("PDA::CompareProviderDetails:: Provider #{provider.id} [\"111111 0A000B\", \"222222 1A111B\"] does not match [\"333333 2A222B\"]")
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
            .with("PDA::CompareProviderDetails:: Provider #{provider.id} [\"111111 0A000B\", \"222222 1A111B\"] does not match [\"111111 0A000B\"]")
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
            .with("PDA::CompareProviderDetails:: Provider #{provider.id} [\"111111 0A000B\", \"222222 1A111B\"] does not match [\"111111 0A000B\", \"222222 1A111B\", \"333333 2A222B\"]")
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
          .with("PDA::CompareProviderDetails:: User #{provider.id} PDA::ProviderDetailsRetriever::ApiError")
      end
    end
  end

  def stub_provider_offices
    stub_request(:get, %r{#{Rails.configuration.x.pda.url}/provider-user/.*/provider-offices})
      .to_return(
        status: 200,
        body: provider_offices_json,
        headers: { "Content-Type" => "application/json; charset=utf-8" },
      )
  end

  def provider_offices_json
    {
      firm: {
        ccmsFirmId: 99_999,
        firmId: 1639,
        firmName: "Test firm",
        firmNumber: "1639",
      },
      officeCodes: [
        {
          ccmsFirmOfficeId: 111_111,
          firmOfficeCode: "0A000B",
        },
        {
          ccmsFirmOfficeId: 222_222,
          firmOfficeCode: "1A111B",
        },
      ],
      user: {
        ccmsContactId: 494_000,
      },
    }.to_json
  end

  def stub_provider_firm_offices
    stub_request(:get, %r{#{Rails.configuration.x.pda.url}/provider-firms/.*/provider-offices})
    .to_return(
      status: 200,
      body: provider_firm_offices_json,
      headers: { "Content-Type" => "application/json; charset=utf-8" },
    )
  end

  def provider_firm_offices_json
    {
      firm: {
        ccmsFirmId: 99_999,
        firmId: 1639,
        firmName: "Test firm",
        firmNumber: "1639",
      },
      offices: [
        {
          ccmsFirmOfficeId: 111_111,
          firmOfficeCode: "0A000B",
        },
        {
          ccmsFirmOfficeId: 222_222,
          firmOfficeCode: "1A111B",
        },
      ],
    }.to_json
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
end
