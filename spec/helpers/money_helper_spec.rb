require 'rails_helper'

RSpec.describe MoneyHelper, type: :helper do
  let(:bank_account_gbp) { create(:bank_account, currency: 'GBP') }
  let(:bank_account_eur) { create(:bank_account, currency: 'EUR') }
  let(:bank_account_usd) { create(:bank_account, currency: 'USD') }
  let(:bank_account_rsa) { create(:bank_account, currency: 'RSA') }

  describe '#currency_symbol' do
    it 'return pound symbol' do
      expect(currency_symbol(bank_account_gbp.currency)).to eq '£'
    end

    it 'return euro symbol' do
      expect(currency_symbol(bank_account_eur.currency)).to eq '€'
    end

    it 'return dollor symbol' do
      expect(currency_symbol(bank_account_usd.currency)).to eq '$'
    end

    it 'return currency code' do
      expect(currency_symbol(bank_account_rsa.currency)).to eq 'RSA'
    end
  end

  describe '#display_value_with_symbol' do
    it 'return value with pound symbol' do
      expect(display_value_with_symbol(bank_account_gbp.balance, bank_account_gbp.currency)).to eq "£#{bank_account_gbp.balance}"
    end

    it 'return value with euro symbol' do
      expect(display_value_with_symbol(bank_account_eur.balance, bank_account_eur.currency)).to eq "€#{bank_account_eur.balance}"
    end

    it 'return value with dollor symbol' do
      expect(display_value_with_symbol(bank_account_usd.balance, bank_account_usd.currency)).to eq "$#{bank_account_usd.balance}"
    end

    it 'return value with currency code' do
      expect(display_value_with_symbol(bank_account_rsa.balance, bank_account_rsa.currency)).to eq "#{bank_account_rsa.currency}#{bank_account_rsa.balance}"
    end
  end
end
