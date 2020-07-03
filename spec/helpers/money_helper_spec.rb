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

  describe '#number_to_currency_or_original_string' do
    let(:result) { number_to_currency_or_original_string(value) }

    context 'is a number' do
      let(:value) { BigDecimal('12_345.5', 12) }

      it 'formats the currency' do
        expect(result).to eq '12,345.50'
      end
    end

    context 'invalid numeric string' do
      let(:value) { '12345.5678' }

      it 'returns original value' do
        expect(result).to eq '12345.5678'
      end
    end

    context 'invalid alphanumeric string' do
      let(:value) { '123xc45.5678' }

      it 'returns original value' do
        expect(result).to eq '123xc45.5678'
      end
    end
  end
end
