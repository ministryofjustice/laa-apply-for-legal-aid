require 'rails_helper'

RSpec.describe CurrencyCleaner do
  context 'valid strings' do
    it 'returns the string stripped of commas and pound signs' do
      valid_strings = [
        %w[£1,123,456.78 1123456.78],
        %w[£1,123,456 1123456],
        %w[£1,123.45 1123.45],
        %w[£123456.78 123456.78],
        %w[£1,123 1123],
        %w[£100.12 100.12],
        %w[£100.1 100.1],
        %w[£100 100],
        %w[100 100],
        %w[-100 -100],
        %w[-1,000 -1000]
      ]
      valid_strings.each do |valid_pair|
        expect(CurrencyCleaner.new(valid_pair.first).call).to eq valid_pair.last
      end
    end
  end

  context 'invalid strings' do
    it 'returns the original string' do
      invalid_strings = %w[
        £1,1234,456.78
        £1,123,5656.78
        £1,123,565.78.66
        £1,12£3,565.78
        $1,123,565.78
        £1234,5
      ]

      invalid_strings.each do |invalid_string|
        expect(CurrencyCleaner.new(invalid_string).call).to eq invalid_string
      end
    end
  end
end
