require 'rails_helper'

module HMRC
  RSpec.describe EmploymentPayment do
    subject { described_class.new(struct) }

    context 'valid payment structure' do
      let(:struct) { valid_payment_struct }

      it 'stores and returns required values' do
        expect(subject.payment_date).to eq Date.new(2021, 11, 12)
        expect(subject.gross_pay).to eq 327.59
        expect(subject.tax).to eq(-128)
        expect(subject.national_insurance).to eq(-22.46)
      end
    end

    context 'No entry in struct of employee national insurance contribs or tax' do
      let(:struct) { no_nics_or_tax_struct }
      it 'stores and returns required values' do
        expect(subject.payment_date).to eq Date.new(2021, 10, 14)
        expect(subject.gross_pay).to eq 572.8
        expect(subject.tax).to eq 0
        expect(subject.national_insurance).to eq 0
      end
    end

    context 'No entry in struct for payment date' do
      let(:struct) { no_payment_date_struct }
      it 'raises' do
        expect {
          subject.payment_date
        }.to raise_error KeyError, 'key not found: "paymentDate"'
      end
    end

    context 'No entry in struct for grossEarningsForNics' do
      let(:struct) { no_gross_earnings_struct }
      it 'raises' do
        expect {
          subject.gross_pay
        }.to raise_error KeyError, 'key not found: "grossEarningsForNics"'
      end
    end

    def valid_payment_struct
      {
        'taxYear' => '21-22',
        'payFrequency' => 'W4',
        'weekPayNumber' => 32,
        'paymentDate' => '2021-11-12',
        'paidHoursWorked' => 'A',
        'taxablePayToDate' => 8751.71,
        'taxablePay' => 327.59,
        'totalTaxToDate' => 202,
        'taxDeductedOrRefunded' => -128,
        'employeePensionContribs' => {
          'notPaidYTD' => 202.65, 'notPaid' => 0.01
        },
        'grossEarningsForNics' => {
          'inPayPeriod1' => 327.59
        },
        'totalEmployerNics' => {
          'inPayPeriod1' => 0, 'ytd1' => 523.32
        },
        'employeeNics' => {
          'inPayPeriod1' => -22.46, 'ytd1' => 414.75
        }
      }
    end

    def no_nics_or_tax_struct
      {
        'taxYear' => '21-22',
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
        }
      }
    end

    def no_gross_earnings_struct
      {
        'taxYear' => '21-22',
        'payFrequency' => 'W4',
        'weekPayNumber' => 28,
        'paidHoursWorked' => 'E',
        'taxablePayToDate' => 4045.4,
        'paymentDate' => '2021-10-14',
        'taxablePay' => 572.8,
        'totalTaxToDate' => 0,
        'taxDeductedOrRefunded' => 0
      }
    end

    def no_payment_date_struct
      {
        'taxYear' => '21-22',
        'payFrequency' => 'W4',
        'weekPayNumber' => 28,
        'paidHoursWorked' => 'E',
        'taxablePayToDate' => 4045.4,
        'taxablePay' => 572.8,
        'totalTaxToDate' => 0,
        'taxDeductedOrRefunded' => 0
      }
    end
  end
end
