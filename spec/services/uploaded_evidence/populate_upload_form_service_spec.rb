require "rails_helper"
require_relative "shared_examples_for_uploaded_evidence"

module UploadedEvidence
  RSpec.describe PopulateUploadFormService do
    let(:laa) { create(:legal_aid_application) }
    let(:params) { nil }
    let(:controller) { instance_double Providers::UploadedEvidenceCollectionsController, params:, legal_aid_application: laa }

    describe ".call" do
      let(:service_instance) { instance_double described_class }

      it "instantiates an instance of PopulateUploadFormService and calls :call" do
        allow(described_class).to receive(:new).with(controller).and_return(service_instance)
        allow(service_instance).to receive(:call).and_return(service_instance)

        described_class.call(controller)
        expect(service_instance).to have_received(:call)
      end
    end

    describe "#call" do
      let(:service) { described_class.new(controller) }
      let(:dwp_override) { instance_double DWPOverride, passporting_benefit: "income_related_employment_and_support_allowance" }

      it "populates the upload form" do
        service.call
        expect(service.upload_form).to be_instance_of(Providers::UploadedEvidenceCollectionForm)
      end

      it "translates the name of the passporting benefit in the evidence type translation instance variable" do
        allow(laa).to receive_messages(dwp_override:, allowed_document_categories: %w[benefit_evidence])
        service.call

        expect(service.evidence_type_translation).to eq "Income-related Employment and Support Allowance (ESA)"
      end
    end

    it_behaves_like "An uploaded evidence service"
  end
end
