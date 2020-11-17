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

  describe '#gds_number_to_currency' do
    let(:result) { gds_number_to_currency(value) }

    context 'pounds with pence' do
      let(:value) { 12_345.25 }

      it 'displays pounds and pence' do
        expect(result).to eq '£12,345.25'
      end
    end

    context 'pounds only' do
      let(:value) { 12_345.00 }

      it 'displays pounds only' do
        expect(result).to eq '£12,345'
      end
    end

    context 'preserves other options' do
      let(:value) { 12_345.25 }
      let(:opts) { { unit: '$', delimiter: ' ', separator: ',' } }
      let(:result) { gds_number_to_currency(value, opts) }

      it 'displays pounds only' do
        expect(result).to eq '$12 345,25'
      end
    end

    context 'returns when not numeric' do
      let(:value) { 'fifty' }

      it 'displays pounds only' do
        expect(result).to eq 'fifty'
      end
    end

    context 'BigDecimal' do
      let(:value) { BigDecimal('12345.25') }

      it 'displays pounds and pence when BigDecimal' do
        expect(result).to eq '£12,345.25'
      end
    end
  end
end
