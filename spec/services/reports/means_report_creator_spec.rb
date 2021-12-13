require 'rails_helper'

RSpec.describe Reports::MeansReportCreator do
  subject do
    # dont' match on path - webpacker keeps changing the second part of the path
    VCR.use_cassette('stylesheets2', match_requests_on: %i[method host headers]) do
      described_class.call(legal_aid_application)
    end
  end

  describe '.call' do
    context 'V3 CFE Result' do
      let(:legal_aid_application) do
        create :legal_aid_application, :with_proceeding_types, :with_everything, :with_cfe_v3_result, :generating_reports, ccms_submission: ccms_submission
      end
      let(:ccms_submission) { create :ccms_submission, :case_ref_obtained }

      it 'attaches means_report.pdf to the application' do
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

      context 'ccms case ref does not exist' do
        let(:legal_aid_application) do
          create :legal_aid_application, :with_proceeding_types, :with_everything, :with_cfe_v3_result, :generating_reports, ccms_submission: ccms_submission
        end
        let(:ccms_submission) { create :ccms_submission }

        before do
          allow_any_instance_of(CCMS::Submission).to receive(:process!).with(any_args).and_return(true)
        end

        it 'processes the existing ccms submission' do
          expect(legal_aid_application.reload.ccms_submission).to receive(:process!)
          subject
        end

        context 'ccms submission does not exist' do
          let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_everything, :with_cfe_v3_result, :generating_reports, ccms_submission: nil }

          before do
            allow(legal_aid_application).to receive(:case_ccms_reference).and_return(nil)
            allow(legal_aid_application).to receive(:create_ccms_submission).and_return(ccms_submission)
          end

          it 'creates a ccms submission' do
            expect(legal_aid_application.reload).to receive(:create_ccms_submission)
            expect_any_instance_of(described_class).to receive(:process_ccms_submission)
            subject
          end
        end
      end
    end

    context 'V4 CFE result' do
      let(:da002) { create :proceeding_type, ccms_code: 'DA002' }
      let(:da006) { create :proceeding_type, ccms_code: 'DA006' }
      let(:legal_aid_application) do
        create :legal_aid_application, :with_proceeding_types, :with_everything, :with_cfe_v4_result,
               :generating_reports, ccms_submission: ccms_submission, explicit_proceeding_types: [da002, da006]
      end
      let(:ccms_submission) { create :ccms_submission, :case_ref_obtained }

      it 'attaches means_report.pdf to the application' do
        expect(Providers::MeansReportsController.renderer).to receive(:render).and_call_original
        subject
        legal_aid_application.reload
        expect(legal_aid_application.means_report.document.content_type).to eq('application/pdf')
        expect(legal_aid_application.means_report.document.filename).to eq('means_report.pdf')
      end

      context 'when an attachment record exists' do
        let!(:attachment) { create :attachment, :means_report, legal_aid_application: legal_aid_application }
        let(:expected_log) { "ReportsCreator: Means report already exists for #{legal_aid_application.id} and is downloadable" }
        before { allow(Rails.logger).to receive(:info) }

        it 'does not attach a report if one already exists' do
          expect { subject }.not_to change { Attachment.count }
          expect(Rails.logger).to have_received(:info).with(expected_log).once
        end

        context 'when the attachment has no document' do
          let(:expected_log) { "ReportsCreator: Means report already exists for #{legal_aid_application.id}" }
          before do
            allow(legal_aid_application).to receive(:means_report).and_return(attachment)
            allow(attachment).to receive(:document).and_return(nil)
          end

          it 'creates a new report if the existing one is not downloadable' do
            # the count won';'t change as we delete one and create one
            expect { subject }.not_to change { Attachment.count }
            # check the original one has been deleted
            expect { attachment.reload }.to raise_error(ActiveRecord::RecordNotFound)
            expect(Rails.logger).to have_received(:info).with(expected_log)
          end
        end
      end

      context 'ccms case ref does not exist' do
        let(:ccms_submission) { create :ccms_submission }

        before do
          allow_any_instance_of(CCMS::Submission).to receive(:process!).with(any_args).and_return(true)
        end

        it 'processes the existing ccms submission' do
          expect(legal_aid_application.reload.ccms_submission).to receive(:process!)
          subject
        end
      end

      context 'ccms submission does not exist' do
        let(:ccms_submission) { nil }
        before do
          RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
          allow(legal_aid_application).to receive(:create_ccms_submission).and_return(ccms_submission)
        end

        after do
          RSpec::Mocks.configuration.allow_message_expectations_on_nil = false
        end

        it 'creates a ccms submission' do
          expect(legal_aid_application.reload).to receive(:create_ccms_submission)
          expect(nil).to receive(:process!)
          subject
        end
      end
    end
  end
end
