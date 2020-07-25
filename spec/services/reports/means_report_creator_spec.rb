require 'rails_helper'

RSpec.describe Reports::MeansReportCreator do
  let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_everything, :with_cfe_v2_result, :generating_reports }

  subject { described_class.call(legal_aid_application) }

  describe '.call' do
    it 'attaches means_report.pdf to the application' do
      expect_any_instance_of(CCMS::Requestors::ReferenceDataRequestor).to receive(:call)
      expect(Providers::MeansReportsController.renderer).to receive(:render).and_call_original
      subject
      legal_aid_application.reload
      expect(legal_aid_application.means_report.document.content_type).to eq('application/pdf')
      expect(legal_aid_application.means_report.document.filename).to eq('means_report.pdf')
    end

    it 'does not attach a report if one already exists' do
      create :attachment, :means_report, legal_aid_application: legal_aid_application
      expect { subject }.not_to change { Attachment.count }
    end
  end
end
