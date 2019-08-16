require 'rails_helper'

RSpec.describe Reports::MeritsReportCreator do
  let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_everything, state: :generating_reports }

  subject { described_class.call(legal_aid_application) }

  describe '.call' do
    it 'attaches merits_report.pdf to the application' do
      expect(Providers::MeritsReportsController.renderer).to receive(:render).and_call_original
      subject
      legal_aid_application.reload
      expect(legal_aid_application.merits_report.content_type).to eq('application/pdf')
      expect(legal_aid_application.merits_report.filename).to eq('merits_report.pdf')
    end
  end
end
