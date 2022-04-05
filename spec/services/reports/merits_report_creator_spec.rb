require "rails_helper"

RSpec.describe Reports::MeritsReportCreator do
  let(:legal_aid_application) do
    create :legal_aid_application,
           :with_proceedings,
           :with_everything,
           :generating_reports,
           explicit_proceedings: %i[da004],
           set_lead_proceeding: :da004,
           ccms_submission: ccms_submission
  end
  let(:da004) { legal_aid_application.proceedings.find_by(ccms_code: "DA004") }
  let!(:chances_of_success) do
    create :chances_of_success, :with_optional_text, proceeding: da004
  end

  let(:ccms_submission) { create :ccms_submission, :case_ref_obtained }

  subject do
    # dont' match on path - webpacker keeps changing the second part of the path
    VCR.use_cassette("stylesheets2", match_requests_on: %i[method host headers]) do
      described_class.call(legal_aid_application)
    end
  end

  describe ".call" do
    it "attaches merits_report.pdf to the application" do
      expect(Providers::MeritsReportsController.renderer).to receive(:render).and_call_original
      subject
      legal_aid_application.reload
      expect(legal_aid_application.merits_report.document.content_type).to eq("application/pdf")
      expect(legal_aid_application.merits_report.document.filename).to eq("merits_report.pdf")
    end

    context "when an attachment record exists" do
      let!(:attachment) { create :attachment, :merits_report, legal_aid_application: legal_aid_application }
      let(:expected_log) { "ReportsCreator: Merits report already exists for #{legal_aid_application.id} and is downloadable" }

      before { allow(Rails.logger).to receive(:info) }

      it "does not attach a report if one already exists" do
        expect { subject }.not_to change(Attachment, :count)
        expect(Rails.logger).to have_received(:info).with(expected_log).once
      end

      context "when the attachment has no document" do
        let(:expected_log) { "ReportsCreator: Merits report already exists for #{legal_aid_application.id}" }

        before do
          allow(legal_aid_application).to receive(:merits_report).and_return(attachment)
          allow(attachment).to receive(:document).and_return(nil)
        end

        it "creates a new report if the existing one is not downloadable" do
          # the count won';'t change as we delete one and create one
          expect { subject }.not_to change(Attachment, :count)
          # check the original one has been deleted
          expect { attachment.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect(Rails.logger).to have_received(:info).with(expected_log)
        end
      end
    end

    context "ccms case ref does not exist" do
      let(:legal_aid_application) do
        create :legal_aid_application,
               :with_proceedings,
               :with_everything,
               :generating_reports,
               ccms_submission: ccms_submission,
               explicit_proceedings: %i[da004],
               set_lead_proceeding: :da004
      end

      let(:da004) { legal_aid_application.proceedings.find_by(ccms_code: "DA004") }
      let!(:chances_of_success) do
        create :chances_of_success, :with_optional_text, proceeding: da004
      end

      let(:ccms_submission) { create :ccms_submission }

      before do
        allow_any_instance_of(CCMS::Submission).to receive(:process!).with(any_args).and_return(true)
      end

      it "processes the existing ccms submission" do
        expect(legal_aid_application.reload.ccms_submission).to receive(:process!)
        subject
      end

      context "ccms submission does not exist" do
        let!(:legal_aid_application) do
          create :legal_aid_application,
                 :with_proceedings,
                 :with_everything,
                 :generating_reports,
                 explicit_proceedings: %i[da004],
                 set_lead_proceeding: :da004
        end
        let(:ccms_submission) { create :ccms_submission }

        let(:da004) { legal_aid_application.proceedings.find_by(ccms_code: "DA004") }
        let!(:chances_of_success) do
          create :chances_of_success, :with_optional_text, proceeding: da004
        end

        before do
          allow(legal_aid_application).to receive(:case_ccms_reference).and_return(nil)
          allow(legal_aid_application).to receive(:create_ccms_submission).and_return(ccms_submission)
        end

        it "creates a ccms submission" do
          expect(legal_aid_application.reload).to receive(:create_ccms_submission)
          expect_any_instance_of(described_class).to receive(:process_ccms_submission)
          subject
        end
      end
    end
  end
end
