require 'rails_helper'

RSpec.describe TransactionPeriodHelper, type: :helper do
  let(:application) { create :legal_aid_application, :with_transaction_period }

  describe '#date_from(application)' do
    it 'returns a valid date' do
      expect(helper.date_from(application)).to eq '29 09 2020'
    end
  end

  describe '#date_to(application)' do
    it 'returns a valid date' do
      expect(helper.date_to(application)).to eq '29 09 2020'
    end
  end
end
