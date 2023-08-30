require "rails_helper"

RSpec.describe ApplicantAccountPresenter do
  subject(:applicant_account_presenter) { described_class.new(applicant.bank_providers.first) }

  let!(:applicant) { create(:applicant) }
  let(:addresses) do
    [{ address: Faker::Address.building_number,
       city: Faker::Address.city,
       zip: Faker::Address.zip }]
  end
  let!(:applicant_bank_provider) { create(:bank_provider, applicant_id: applicant.id) }

  let!(:applicant_bank_account_holder) do
    create(:bank_account_holder, bank_provider_id: applicant_bank_provider.id,
                                 addresses:)
  end

  let!(:applicant_bank_account) do
    create(:bank_account, bank_provider_id: applicant_bank_provider.id, currency: "GBP")
  end

  describe "#main_account_holder_name" do
    it "return last account name" do
      expect(applicant_account_presenter.main_account_holder_name).to eq(applicant_bank_account_holder.full_name)
    end
  end

  describe "#main_account_holder_address" do
    it "return last account holder address" do
      expect(applicant_account_presenter.main_account_holder_address).to eq(addresses.first.values.join(", "))
    end
  end

  describe "#name" do
    it "return applicant name" do
      expect(applicant_account_presenter.name).to eq(applicant_bank_provider.name)
    end
  end

  describe "#bank_accounts" do
    it "return bank accounts" do
      expect(applicant_account_presenter.bank_accounts.count).to eq(applicant_bank_provider.bank_accounts.count)
    end
  end
end
