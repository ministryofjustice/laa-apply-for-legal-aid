require 'rails_helper'

RSpec.describe TransactionPeriodHelper, type: :helper do
  let(:application) { create :legal_aid_application, transaction_period_start_on: 'Thu, 21 Oct 2020', transaction_period_finish_on: 'Thu, 21 Jan 2021' }

  describe '#date_from(application)' do
    it 'returns a valid date' do
      expect(helper.date_from(application)).to eq '21 October 2020'
    end
  end

  describe '#date_to(application)' do
    it 'returns a valid date' do
      expect(helper.date_to(application)).to eq '21 January 2021'
    end
  end
end
