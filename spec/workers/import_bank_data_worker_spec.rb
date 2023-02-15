require "rails_helper"
require "sidekiq/testing"

RSpec.describe ImportBankDataWorker, type: :worker do
  subject(:perform_job) { described_class.perform_async(legal_aid_application.id) }

  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
  let(:applicant) { build(:applicant, :with_encrypted_true_layer_token) }

  let(:worker_status) { Sidekiq::Status.get_all(perform_job) }

  around do |example|
    described_class.clear
    Sidekiq::Testing.inline! { example.run }
  end

  before do
    allow(TrueLayer::BankDataImportService)
      .to receive(:call)
      .and_return(bank_data_import_result)
  end

  context "when the bank data import is successful" do
    let(:bank_data_import_result) do
      instance_double(
        TrueLayer::BankDataImportService,
        success?: true,
      )
    end

    it "does not save any errors" do
      expect(worker_status).not_to have_key("errors")
    end
  end

  context "when the bank data import is not successful" do
    let(:bank_data_import_result) do
      instance_double(
        TrueLayer::BankDataImportService,
        success?: false,
        errors: { description: "Something went wrong", error: :not_supported },
      )
    end

    it "saves the errors" do
      errors = worker_status["errors"]

      expect(errors)
        .to include("Something went wrong")
        .and include("not_supported")
    end
  end
end
