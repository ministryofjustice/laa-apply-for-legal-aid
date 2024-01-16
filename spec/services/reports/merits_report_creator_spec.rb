require "rails_helper"

RSpec.describe Reports::MeritsReportCreator do
  subject(:call) do
    # don't match on path - webpacker keeps changing the second part of the path
    VCR.use_cassette("stylesheets2", match_requests_on: %i[method host headers]) do
      instance.call
    end
  end

  let(:legal_aid_application) do
    create(:legal_aid_application,
           :with_proceedings,
           :with_everything,
           :generating_reports,
           explicit_proceedings: %i[da001],
           set_lead_proceeding: :da001,
           ccms_submission:)
  end
  let(:da001) { legal_aid_application.proceedings.find_by(ccms_code: "DA001") }
  let(:ccms_submission) { create(:ccms_submission, :case_ref_obtained) }
  let(:smtl) { create(:legal_framework_merits_task_list, :da001, legal_aid_application:) }
  let(:instance) { described_class.new(legal_aid_application) }

  before do
    create(:chances_of_success, :with_optional_text, proceeding: da001)
    allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
  end

  describe ".call" do
    it "attaches merits_report.pdf to the application" do
      expect(Providers::MeritsReportsController.renderer).to receive(:render).and_call_original
      call
      legal_aid_application.reload
      expect(legal_aid_application.merits_report.document.content_type).to eq("application/pdf")
      expect(legal_aid_application.merits_report.document.filename).to eq("merits_report.pdf")
    end

    context "when an attachment record exists" do
      let!(:attachment) { create(:attachment, :merits_report, legal_aid_application:) }
      let(:expected_log) { "ReportsCreator: Merits report already exists for #{legal_aid_application.id} and is downloadable" }

      before { allow(Rails.logger).to receive(:info) }

      it "does not attach a report if one already exists" do
        expect { call }.not_to change(Attachment, :count)
        expect(Rails.logger).to have_received(:info).with(expected_log).once
      end

      context "and the attachment has no document" do
        let(:expected_log) { "ReportsCreator: Merits report already exists for #{legal_aid_application.id}" }

        before do
          allow(legal_aid_application).to receive(:merits_report).and_return(attachment)
          allow(attachment).to receive(:document).and_return(nil)
        end

        it "creates a new report if the existing one is not downloadable" do
          # the count won';'t change as we delete one and create one
          expect { call }.not_to change(Attachment, :count)
          # check the original one has been deleted
          expect { attachment.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect(Rails.logger).to have_received(:info).with(expected_log)
        end
      end
    end

    context "when the ccms case ref does not exist" do
      let(:legal_aid_application) do
        create(:legal_aid_application,
               :with_proceedings,
               :with_everything,
               :generating_reports,
               ccms_submission:,
               explicit_proceedings: %i[da001],
               set_lead_proceeding: :da001)
      end

      let(:da001) { legal_aid_application.proceedings.find_by(ccms_code: "DA001") }
      let(:ccms_submission) { create(:ccms_submission) }

      before do
        create(:chances_of_success, :with_optional_text, proceeding: da001)
        allow(ccms_submission).to receive(:process!).with(any_args).and_return(true)
      end

      it "processes the existing ccms submission" do
        expect(legal_aid_application.reload.ccms_submission).to receive(:process!)
        call
      end

      context "and the ccms submission does not exist" do
        let!(:legal_aid_application) do
          create(:legal_aid_application,
                 :with_proceedings,
                 :with_everything,
                 :generating_reports,
                 explicit_proceedings: %i[da001],
                 set_lead_proceeding: :da001)
        end
        let(:ccms_submission) { create(:ccms_submission) }

        let(:da001) { legal_aid_application.proceedings.find_by(ccms_code: "DA001") }

        before do
          create(:chances_of_success, :with_optional_text, proceeding: da001)
          allow(legal_aid_application).to receive_messages(case_ccms_reference: nil, create_ccms_submission: ccms_submission)
        end

        it "creates a ccms submission" do
          expect(legal_aid_application.reload).to receive(:create_ccms_submission)
          expect(instance).to receive(:process_ccms_submission)
          call
        end
      end
    end
  end
end
