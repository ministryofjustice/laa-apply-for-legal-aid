require "rails_helper"
require_relative "shared_examples_for_uploaded_evidence"

module UploadedEvidence
  RSpec.describe DeletionService do
    let(:laa) { create(:legal_aid_application) }
    let(:controller) { instance_double Providers::UploadedEvidenceCollectionsController, params:, legal_aid_application: laa }

    describe ".call" do
      let(:service_instance) { instance_double described_class }
      let(:params) { { delete_button: "Delete" } }

      it "instantiates an instance of DeletionService and calls :call" do
        allow(described_class).to receive(:new).with(controller).and_return(service_instance)
        allow(service_instance).to receive(:call).and_return(service_instance)

        described_class.call(controller)
        expect(service_instance).to have_received(:call)
      end
    end

    describe "#call" do
      let!(:attachment) { create(:attachment, :uploaded_evidence_collection, original_filename: "my_dummy_file.pdf") }
      let(:params) { { delete_button: "Delete", attachment_id: attachment.id } }
      let(:service) { described_class.new(controller) }

      it "deletes the attachment" do
        expect { service.call }.to change(Attachment, :count).by(-1)
      end

      it "populates the deletion message" do
        service.call
        expect(service.successfully_deleted).to eq "my_dummy_file.pdf has been successfully deleted."
      end

      it "sets the next action to :show" do
        service.call
        expect(service.next_action).to eq :show
      end
    end

    it_behaves_like "An uploaded evidence service"
  end
end
