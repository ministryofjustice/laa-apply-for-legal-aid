require 'rails_helper'

RSpec.describe CashTransaction, type: :model do
  let(:application1) { create :legal_aid_application }
  let(:application2) { create :legal_aid_application }
  let(:benefits) { create :transaction_type, :benefits }
  let(:pension) { create :transaction_type, :pension }

  before do
    cash_transactions_for(application1, 1)
    cash_transactions_for(application2, 2)
  end

  def cash_transactions_for(application, multiplier)
    (1..3).each do |number|
      create :cash_transaction, transaction_type: benefits, legal_aid_application: application, transaction_date: number.month.ago, amount: 100 * multiplier, month_number: number
      create :cash_transaction, transaction_type: pension, legal_aid_application: application, transaction_date: number.month.ago, amount: 200 * multiplier, month_number: number
    end
  end

  describe 'amounts' do
    it 'returns a hash of totals for a specific application' do
      expect(CashTransaction.amounts_for_application(application1)).to eq expected_result1
      expect(CashTransaction.amounts_for_application(application2)).to eq expected_result2
    end
  end

  context 'date formatting' do
    let(:ctx) { create :cash_transaction, transaction_date: Date.new(2021, 2, 2), month_number: 1 }

    describe '.period_start' do
      it 'displays 1st day and month of transaction date' do
        expect(ctx.period_start).to eq '01 Feb'
      end
    end

    describe '.period_end' do
      it 'displays last day and month of transaction date' do
        expect(ctx.period_end).to eq '28 Feb'
      end
    end
    end

  def expected_result1
    {
      'benefits' => 300,
      'pension' => 600
    }
  end

  def expected_result2
    {
      'benefits' => 600,
      'pension' => 1200
    }
  end
end
