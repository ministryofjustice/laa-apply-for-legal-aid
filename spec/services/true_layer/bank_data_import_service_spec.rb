require "rails_helper"

RSpec.describe TrueLayer::BankDataImportService do
  let(:legal_aid_application) do
    create(
      :legal_aid_application,
      :with_transaction_period,
      applicant:,
    )
  end

  let(:applicant) { build(:applicant, :with_encrypted_true_layer_token) }
  let(:mock_data) { TrueLayerHelpers::MOCK_DATA }
  let(:bank_provider) { applicant.bank_providers.last }

  describe "#call" do
    subject(:import_bank_data) { described_class.call(legal_aid_application:) }

    before { stub_true_layer }

    context "when there are no API errors" do
      it "imports the bank provider" do
        expect { import_bank_data }
          .to change { applicant.bank_providers.count }.by(1)

        expect(bank_provider).to have_attributes(
          credentials_id: mock_data[:provider][:credentials_id],
          true_layer_provider_id: mock_data[:provider][:provider][:provider_id],
        )
      end

      it "imports the bank accounts" do
        expect { import_bank_data }
          .to change(BankAccount, :count).by(mock_data[:accounts].count)

        expect(bank_provider.bank_accounts.pluck(:true_layer_id))
          .to contain_exactly(*mock_data[:accounts].pluck(:account_id))
      end

      it "imports the account balances" do
        import_bank_data

        mock_account_balances = mock_data[:accounts].map do |account|
          account.fetch(:balance).fetch(:current)
        end

        expect(bank_provider.bank_accounts.pluck(:balance))
          .to contain_exactly(*mock_account_balances)
      end

      it "imports the bank account holders" do
        expect { import_bank_data }
          .to change(BankAccountHolder, :count)
          .by(mock_data[:account_holders].count)
      end

      it "imports the transactions" do
        mock_transaction_ids = mock_data[:accounts].flat_map do |account|
          account.fetch(:transactions).pluck(:transaction_id)
        end

        expect { import_bank_data }
          .to change(BankTransaction, :count).by(mock_transaction_ids.count)

        transaction_ids = bank_provider
          .bank_accounts
          .flat_map(&:bank_transactions)
          .pluck(:true_layer_id)

        expect(transaction_ids).to contain_exactly(*mock_transaction_ids)
      end

      it "is successful" do
        expect(import_bank_data).to be_success
      end
    end

    context "when the provider API call is failing" do
      before { stub_true_layer_error(path: "data/v1/me") }

      it "returns an error" do
        expect(import_bank_data.errors).to have_key(:bank_data_import)
      end
    end

    context "when a subsequent API call is failing" do
      before { stub_true_layer_error(path: "data/v1/accounts") }

      it "does not import anything" do
        expect { import_bank_data }
          .to not_change(BankProvider, :count)
          .and not_change(BankAccount, :count)
          .and not_change(BankAccountHolder, :count)
          .and not_change(BankTransaction, :count)
      end

      it "returns an error" do
        expect(import_bank_data.errors).to have_key(:bank_data_import)
      end

      it "saves the error" do
        import_bank_data

        expect(applicant.bank_errors.first).to have_attributes(
          applicant:,
          bank_name: mock_data[:provider][:provider][:display_name],
          error: match(/:import_accounts/),
        )
      end
    end

    context "when mock_true_layer_data is on" do
      let(:sample_data) { TrueLayer::SampleData }

      before { Setting.create!(mock_true_layer_data: true) }

      it "uses the Mock ApiClient" do
        expect(TrueLayer::ApiClient).not_to receive(:new)
        expect(TrueLayer::ApiClientMock).to receive(:new).and_call_original
        import_bank_data
      end

      it "imports the sample data" do
        expect { import_bank_data }
          .to change { applicant.bank_providers.count }.by(1)

        expect(bank_provider.credentials_id)
          .to eq(sample_data::PROVIDERS.first[:credentials_id])
        expect(bank_provider.bank_accounts.pluck(:true_layer_id))
          .to contain_exactly(*sample_data::ACCOUNTS.pluck(:account_id))
      end
    end
  end
end
