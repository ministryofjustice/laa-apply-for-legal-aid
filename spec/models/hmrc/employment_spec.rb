require 'rails_helper'

module HMRC
  RSpec.describe Employment do
    describe '.new' do
      subject { described_class.new(income_array) }

      let(:expected_payment_dates) do
        [
          Date.new(2021, 11, 11),
          Date.new(2021, 10, 14),
          Date.new(2021, 9, 16)
        ]
      end

      it 'sorts payments into date order most recent first' do
        expect(subject.payments.map(&:payment_date)).to eq expected_payment_dates
      end

      it 'has three EmploymentPayment objects' do
        expect(subject.payments.size).to eq 3
        expect(subject.payments.map(&:class).uniq).to eq [EmploymentPayment]
      end
    end

    def income_array
      [
        {
          'taxYear' => '21-22',
          'payFrequency' => 'W4',
          'weekPayNumber' => 24,
          'paymentDate' => '2021-09-16',
          'paidHoursWorked' => 'E',
          'taxablePayToDate' => 3472.6,
          'taxablePay' => 572.8,
          'totalTaxToDate' => 0,
          'taxDeductedOrRefunded' => 0,
          'grossEarningsForNics' => {
            'inPayPeriod1' => 572.8
          }
        },
        { 'taxYear' => '21-22',
          'payFrequency' => 'W4',
          'weekPayNumber' => 32,
          'paymentDate' => '2021-11-11',
          'paidHoursWorked' => 'E',
          'taxablePayToDate' => 4618.2,
          'taxablePay' => 572.8,
          'totalTaxToDate' => 0,
          'taxDeductedOrRefunded' => 0,
          'grossEarningsForNics' => {
            'inPayPeriod1' => 572.8
          } },
        { 'taxYear' => '21-22',
          'payFrequency' => 'W4',
          'weekPayNumber' => 28,
          'paymentDate' => '2021-10-14',
          'paidHoursWorked' => 'E',
          'taxablePayToDate' => 4045.4,
          'taxablePay' => 572.8,
          'totalTaxToDate' => 0,
          'taxDeductedOrRefunded' => 0,
          'grossEarningsForNics' => {
            'inPayPeriod1' => 572.8
          } }
      ]
    end
  end
end
