require 'rails_helper'

RSpec.describe Reports::ReportsCreator do
  let(:legal_aid_application) do
    create :legal_aid_application,
           :with_proceeding_types,
           :with_ccms_submission,
           :with_everything,
           :with_passported_state_machine,
           :generating_reports
  end

  subject { described_class.call(legal_aid_application) }

  before { allow(EnableCCMSSubmission).to receive(:call).and_return(allow_ccms_submission) }
  let(:allow_ccms_submission) { true }

  describe '.call' do
    context 'when the Setting.enable_ccms_submission? is turned off' do
      let(:allow_ccms_submission) { false }

      it 'updates the state to submission_paused' do
        expect(Reports::MeritsReportCreator).to receive(:call).with(legal_aid_application)
        expect(Reports::MeansReportCreator).to receive(:call).with(legal_aid_application)
        expect(Reports::BankTransactions::BankTransactionReportCreator).to_not receive(:call).with(legal_aid_application)
        subject
        legal_aid_application.reload
        expect(legal_aid_application.state).to eq('submission_paused')
      end
    end

    it 'creates reports and update state' do
      expect(Reports::MeritsReportCreator).to receive(:call).with(legal_aid_application)
      expect(Reports::MeansReportCreator).to receive(:call).with(legal_aid_application)
      expect(Reports::BankTransactions::BankTransactionReportCreator).to_not receive(:call).with(legal_aid_application)
      subject
      legal_aid_application.reload
      expect(legal_aid_application.state).to eq('submitting_assessment')
    end

    context 'when the application is non-passported and has transactions' do
      let(:legal_aid_application) do
        create :legal_aid_application,
               :with_proceeding_types,
               :with_everything,
               :with_ccms_submission,
               :with_benefits_transactions,
               :with_uncategorised_credit_transactions,
               :generating_reports
      end

      it 'creates reports and updates the state' do
        expect(Reports::MeritsReportCreator).to receive(:call).with(legal_aid_application)
        expect(Reports::MeansReportCreator).to receive(:call).with(legal_aid_application)
        expect(Reports::BankTransactions::BankTransactionReportCreator).to receive(:call).with(legal_aid_application)
        subject
        legal_aid_application.reload
        expect(legal_aid_application.state).to eq('submitting_assessment')
      end
    end
  end
end
