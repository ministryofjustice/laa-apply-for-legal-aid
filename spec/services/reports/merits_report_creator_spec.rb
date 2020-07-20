require 'rails_helper'

RSpec.describe Reports::MeritsReportCreator do
  let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_everything, :generating_reports }

  subject { described_class.call(legal_aid_application) }

  describe '.call' do
    it 'attaches merits_report.pdf to the application' do
      expect_any_instance_of(CCMS::Requestors::ReferenceDataRequestor).to receive(:call)
      expect(Providers::MeritsReportsController.renderer).to receive(:render).and_call_original
      subject
      legal_aid_application.reload
      expect(legal_aid_application.merits_report.document.content_type).to eq('application/pdf')
      expect(legal_aid_application.merits_report.document.filename).to eq('merits_report.pdf')
    end

    it 'does not attach a report if one already exists' do
      create :attachment, :merits_report, legal_aid_application: legal_aid_application
      expect { subject }.not_to change { Attachment.count }
    end
  end
end
