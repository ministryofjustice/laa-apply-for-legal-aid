require 'rails_helper'

RSpec.describe Reports::ReportsCreator do
  let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_positive_benefit_check_result, :with_everything, :generating_reports }

  subject { described_class.call(legal_aid_application) }

  describe '.call' do
    it 'creates reports and update state' do
      expect(Reports::MeritsReportCreator).to receive(:call).with(legal_aid_application)
      expect(Reports::MeansReportCreator).to receive(:call).with(legal_aid_application)
      expect(Reports::BankTransactionReportCreator).to_not receive(:call).with(legal_aid_application)
      subject
      legal_aid_application.reload
      expect(legal_aid_application.state).to eq('submitting_assessment')
    end

    context 'when the application is non-passported and has transactions' do
      let(:legal_aid_application) do
        create :legal_aid_application,
               :with_proceeding_types,
               :with_everything,
               :with_benefits_transactions,
               :with_uncategorised_credit_transactions,
               :generating_reports
      end

      it 'creates reports and updates the state' do
        expect(Reports::MeritsReportCreator).to receive(:call).with(legal_aid_application)
        expect(Reports::MeansReportCreator).to receive(:call).with(legal_aid_application)
        expect(Reports::BankTransactionReportCreator).to receive(:call).with(legal_aid_application)
        subject
        legal_aid_application.reload
        expect(legal_aid_application.state).to eq('submitting_assessment')
      end
    end
  end
end
