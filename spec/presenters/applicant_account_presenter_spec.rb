require 'rails_helper'

RSpec.describe ApplicantAccountPresenter do
  let!(:applicant) { create :applicant }
  let(:addresses) do
    [{ address: Faker::Address.building_number,
       city: Faker::Address.city,
       zip: Faker::Address.zip }]
  end
  let!(:applicant_bank_provider) { create(:bank_provider, applicant_id: applicant.id) }

  let!(:applicant_bank_account_holder) do
    create(:bank_account_holder, bank_provider_id: applicant_bank_provider.id,
                                 addresses: addresses)
  end

  let!(:applicant_bank_account) do
    create(:bank_account, bank_provider_id: applicant_bank_provider.id, currency: 'GBP')
  end

  subject(:applicant_account_presenter) { described_class.new(applicant.bank_providers.first) }

  context '#main_account_holder_name' do
    it 'return last account name' do
      expect(subject.main_account_holder_name).to eq(applicant_bank_account_holder.full_name)
    end
  end

  context '#main_account_holder_address' do
    it 'return last account holder address' do
      expect(subject.main_account_holder_address).to eq(addresses.first.values.join(', '))
    end
  end

  context '#name' do
    it 'return applicant name' do
      expect(subject.name).to eq(applicant_bank_provider.name)
    end
  end

  context '#bank_accounts' do
    it 'return bank accounts' do
      expect(subject.bank_accounts.count).to eq(applicant_bank_provider.bank_accounts.count)
    end
  end
end
