require "rails_helper"

module UploadedEvidence
  RSpec.describe SaveAndContinueService do
    let(:laa) { create(:legal_aid_application) }
    let(:params) { nil }

    let(:controller) { instance_double Providers::UploadedEvidenceCollectionsController, params:, legal_aid_application: laa }

    describe ".call" do
      let(:service_instance) { instance_double described_class }

      it "instantiates an instance of SaveAndContinueService and calls :call" do
        allow(described_class).to receive(:new).with(controller).and_return(service_instance)
        allow(service_instance).to receive(:call).and_return(service_instance)

        described_class.call(controller)
        expect(service_instance).to have_received(:call)
      end
    end

    describe "#call" do
      let(:service) { described_class.new(controller) }
      let(:submission_form) { instance_double Providers::UploadedEvidenceSubmissionForm, model: }
      let(:att1) { create(:attachment, :uploaded_evidence_collection, attachment_type: "uncategorised") }
      let(:att2) { create(:attachment, :uploaded_evidence_collection, attachment_type: "client_employment_evidence") }

      before { allow(service).to receive(:submission_form).and_return(submission_form) }

      context "when there is a valid submission form" do
        let(:model) { instance_double UploadedEvidenceCollection, valid?: true }

        context "with no submission files" do
          let(:params) { {} }

          it "does not call update attachment type" do
            expect(service).not_to receive(:update_attachment_type)
            service.call
          end

          it "sets next action to :continue_or_draft" do
            service.call
            expect(service.next_action).to eq :continue_or_draft
          end
        end

        context "with submission files" do
          let(:params) do
            {
              uploaded_evidence_collection: {
                att1.id => "client_employment_evidence",
                att2.id => "gateway_evidence",
              },
              attachment_id: "61c95550-d361-4575-8f7d-a22eabc91831",
              continue_button: "Save and continue",
            }
          end

          it "calls update_attachment_type" do
            expect(service).to receive(:update_attachment_type)
            service.call
          end

          it "calls convert_new_files to pdf" do
            expect(service).to receive(:convert_new_files_to_pdf)
            service.call
          end

          it "sets next action to :save_continue_or_draft" do
            service.call
            expect(service.next_action).to eq :save_continue_or_draft
          end

          it "changes the attachment type according to the parameters" do
            service.call
            expect(att1.reload.attachment_type).to eq "client_employment_evidence"
            expect(att2.reload.attachment_type).to eq "gateway_evidence"
          end
        end
      end

      context "when there is an invalid submission form" do
        let(:model) { instance_double UploadedEvidenceCollection, valid?: false }
        let(:params) do
          {
            uploaded_evidence_collection: {
              att1.id => "uncategorised",
              att2.id => "uncategorised",
            },
            attachment_id: "61c95550-d361-4575-8f7d-a22eabc91831",
            continue_button: "Save and continue",
          }
        end

        it "does not call convert_new_files_to_pdf" do
          expect(service).not_to receive(:convert_new_files_to_pdf)
          service.call
        end

        it "calls populate upload form" do
          expect(service).to receive(:populate_upload_form)
          service.call
        end

        it "sets next action to :show" do
          service.call
          expect(service.next_action).to eq :show
        end
      end
    end
  end
end
