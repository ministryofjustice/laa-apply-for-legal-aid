require 'rails_helper'

RSpec.describe MoneyHelper, type: :helper do
  let(:balance) { 325.42 }
  subject(:humanized_balance) { value_with_currency_unit(balance, currency) }

  describe '#display_value_with_symbol' do
    context 'when the currency is GBP' do
      let(:currency) { 'GBP' }
      it { is_expected.to eq("£#{balance}") }
    end

    context 'when the currency is EUR' do
      let(:currency) { 'EUR' }
      it { is_expected.to eq("€#{balance}") }
    end

    context 'when the currency is USD' do
      let(:currency) { 'USD' }
      it { is_expected.to eq("$#{balance}") }
    end

    context 'when currency is not recognised' do
      let(:currency) { 'RSA' }
      it { is_expected.to eq("#{currency}#{balance}") }
    end
  end
end
