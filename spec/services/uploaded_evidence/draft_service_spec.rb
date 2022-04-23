require "rails_helper"

module UploadedEvidence
  RSpec.describe DraftService do
    let(:laa) { create :legal_aid_application }
    let(:params) { {} }

    let(:controller) { instance_double Providers::UploadedEvidenceCollectionsController, params: params, legal_aid_application: laa }

    describe ".call" do
      let(:service_instance) { instance_double described_class }
      let(:params) { { delete_button: "Delete" } }

      it "instantiates and instance of DraftService and calls :call" do
        allow(described_class).to receive(:new).with(controller).and_return(service_instance)
        allow(service_instance).to receive(:call).and_return(service_instance)

        described_class.call(controller)
      end
    end

    describe "#call" do
      let(:service) { described_class.new(controller) }

      it "populates the submission form" do
        service.call
        expect(service.submission_form).to be_instance_of(Providers::UploadedEvidenceSubmissionForm)
      end

      it "sets the next action to :save_continue_or_draft" do
        service.call
        expect(service.next_action).to eq :save_continue_or_draft
      end
    end
  end
end
