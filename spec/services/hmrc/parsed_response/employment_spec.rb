require 'rails_helper'

module HMRC
  module ParsedResponse
    RSpec.describe Employment do
      describe '.new' do
        let(:hmrc_response) { create :hmrc_response, :example1_usecase1 }
        let(:laa) { hmrc_response.legal_aid_application }
        let(:employment_income_summary) { EmploymentIncomeSummary.new(laa) }
        let(:employment) { employment_income_summary.employments.first }

        it 'sorts payments into date order most recent first' do
          expect(employment.payments.map(&:formatted_payment_date)).to eq %w[2021-11-28 2021-10-28 2021-09-28 2021-08-28]
        end

        it 'has four EmploymentPayment objects' do
          expect(employment.payments.size).to eq 4
          expect(employment.payments.map(&:class).uniq).to eq [EmploymentPayment]
        end
      end
    end
  end
end
