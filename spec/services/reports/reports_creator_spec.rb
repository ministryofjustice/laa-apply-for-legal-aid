require 'rails_helper'

RSpec.describe Reports::ReportsCreator do
  let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_everything, state: :generating_reports }

  subject { described_class.call(legal_aid_application) }

  describe '.call' do
    it 'attaches merits_report.pdf to the application' do
      expect(Reports::MeritsReportCreator).to receive(:call).with(legal_aid_application)
      expect(Reports::MeansReportCreator).to receive(:call).with(legal_aid_application)
      subject
      legal_aid_application.reload
      expect(legal_aid_application.state).to eq('assessment_submitted')
    end
  end
end
