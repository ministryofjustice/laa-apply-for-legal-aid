require "rails_helper"

RSpec.describe Admin::LegalAidApplications::SubmissionsController do
  let(:admin_user) { create(:admin_user) }
  let(:legal_aid_application) { create(:legal_aid_application, :with_everything, :with_ccms_submission) }

  before { sign_in admin_user }

  describe "GET show" do
    subject(:get_request) { get admin_legal_aid_applications_submission_path(legal_aid_application) }

    it "renders successfully" do
      get_request
      expect(response).to be_successful
    end

    it "displays correct application" do
      get_request
      expect(response.body).to include(legal_aid_application.application_ref)
    end

    context "when no ccms submission exists" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_everything) }

      it "does not display submission data" do
        get_request
        expect(response.body).not_to include("CCMS Submission")
      end
    end
  end

  context "with Downloads" do
    let(:submission) { legal_aid_application.ccms_submission }
    let!(:history) { create(:ccms_submission_history, :with_xml, submission:) }

    describe "GET download_response_xml" do
      subject(:get_request) { get download_xml_response_admin_legal_aid_applications_submission_path(history, format: :xml) }

      it "is successful" do
        get_request
        expect(response).to be_successful
      end

      it "downloads the file" do
        expect_any_instance_of(described_class).to receive(:send_data)
        get_request
      end
    end

    describe "GET download_request_xml" do
      subject(:get_request) { get download_xml_request_admin_legal_aid_applications_submission_path(history, format: :xml) }

      it "is successful" do
        get_request
        expect(response).to be_successful
      end

      it "downloads the file" do
        expect_any_instance_of(described_class).to receive(:send_data)
        get_request
      end
    end

    context "with pdf" do
      describe "GET download_means_report" do
        subject(:get_request) { get download_means_report_admin_legal_aid_applications_submission_path(legal_aid_application, format: :pdf) }

        it "downloads the file" do
          expect_any_instance_of(described_class).to receive(:download_report).with(:means)
          get_request
        end
      end

      describe "GET download_merits_report" do
        subject(:get_request) { get download_merits_report_admin_legal_aid_applications_submission_path(legal_aid_application, format: :pdf) }

        it "downloads the file" do
          expect_any_instance_of(described_class).to receive(:download_report).with(:merits)
          get_request
        end
      end
    end
  end

  describe "nil value" do
    subject(:get_request) { get download_xml_response_admin_legal_aid_applications_submission_path(history, format: :xml) }

    let(:submission) { legal_aid_application.ccms_submission }
    let!(:history) { create(:ccms_submission_history, :without_xml, submission:) }

    it { expect { get_request }.to raise_error StandardError, "No data found" }
  end
end
