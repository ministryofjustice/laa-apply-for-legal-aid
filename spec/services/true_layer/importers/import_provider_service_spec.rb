require "rails_helper"

RSpec.describe TrueLayer::Importers::ImportProviderService do
  let(:api_client) { TrueLayer::ApiClient.new(SecureRandom.hex) }
  let(:applicant) { create(:applicant, :with_encrypted_true_layer_token) }
  let(:mock_provider) { TrueLayerHelpers::MOCK_DATA[:provider] }
  let(:bank_provider) { applicant.bank_providers.last }

  describe "#call" do
    subject(:import_provider) { described_class.call(api_client:, applicant:) }

    before { stub_true_layer_response }

    context "when the request is successful" do
      let(:stub_true_layer_response) { stub_true_layer_provider }

      context "when bank provider does not exist" do
        it "adds the bank provider to the applicant" do
          expect { import_provider }
            .to change { applicant.bank_providers.count }.by(1)

          expect(bank_provider).to have_attributes(
            true_layer_response: mock_provider.deep_stringify_keys,
            credentials_id: mock_provider[:credentials_id],
            name: mock_provider[:provider][:display_name],
            true_layer_provider_id: mock_provider[:provider][:provider_id],
          )
        end

        it "returns the bank provider" do
          expect(import_provider.result).to be_a(BankProvider)
        end

        it "is successful" do
          expect(import_provider).to be_success
        end
      end

      context "when the bank provider already exists" do
        before do
          create(
            :bank_provider,
            applicant:,
            true_layer_provider_id: mock_provider[:provider][:provider_id],
          )
        end

        it "updates the applicant's existing bank provider" do
          expect { import_provider }
            .not_to change { applicant.bank_providers.count }

          expect(bank_provider).to have_attributes(
            true_layer_response: mock_provider.deep_stringify_keys,
            credentials_id: mock_provider[:credentials_id],
            name: mock_provider[:provider][:display_name],
            true_layer_provider_id: mock_provider[:provider][:provider_id],
          )
        end

        it "returns the bank provider" do
          expect(import_provider.result).to be_a(BankProvider)
        end

        it "is successful" do
          expect(import_provider).to be_success
        end
      end
    end

    context "when the request is not successful" do
      let(:stub_true_layer_response) { stub_true_layer_error }

      it "does not import the bank provider" do
        expect { import_provider }
          .not_to change { applicant.bank_providers.count }

        expect(applicant.bank_providers).to be_empty
      end

      it "returns nil" do
        expect(import_provider.result).to be_nil
      end

      it "adds an error" do
        expect(import_provider.errors).to have_key(:import_provider)
      end

      it "is not successful" do
        expect(import_provider).not_to be_success
      end
    end
  end
end
