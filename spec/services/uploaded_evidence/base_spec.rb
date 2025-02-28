require "rails_helper"
require_relative "shared_examples_for_uploaded_evidence"
module UploadedEvidence
  RSpec.describe Base do
    subject(:base_service_call) { described_class.call(controller) }

    let(:controller) { instance_double Providers::UploadedEvidenceCollectionsController, params: }

    describe ".call" do
      context "with upload button pressed" do
        let(:params) { { upload_button: "Upload" } }

        it "calls the UploaderService" do
          expect(UploaderService).to receive(:call).with(controller)
          base_service_call
        end
      end

      context "with draft button pressed" do
        let(:params) { { draft_button: "Save and come back later" } }

        it "calls the DraftService" do
          expect(DraftService).to receive(:call).with(controller)
          base_service_call
        end
      end

      context "with delete button pressed" do
        let(:params) { { delete_button: "" } }

        it "calls the DeletionService" do
          expect(DeletionService).to receive(:call).with(controller)
          base_service_call
        end
      end

      context "with save and continue button pressed" do
        let(:params) { { continue_button: "Save and continue" } }

        it "calls the SaveAndContinueService" do
          expect(SaveAndContinueService).to receive(:call).with(controller)
          base_service_call
        end
      end
    end

    it_behaves_like "An uploaded evidence service"
  end
end
