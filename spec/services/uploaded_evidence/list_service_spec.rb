require "rails_helper"
require_relative "shared_examples_for_uploaded_evidence"

module UploadedEvidence
  RSpec.describe ListService do
    let(:laa) { create(:legal_aid_application) }
    let(:params) { nil }
    let(:allowed_document_categories) { %w[gateway_evidence employment_evidence] }

    let(:expected_attachment_type_options) do
      [
        ["gateway_evidence", "Gateway evidence"],
        ["employment_evidence", "Employment evidence"],
        %w[uncategorised Uncategorised],
      ]
    end

    let(:controller) { instance_double Providers::UploadedEvidenceCollectionsController, params:, legal_aid_application: laa }

    describe ".call" do
      let(:service_instance) { instance_double described_class }

      it "instantiates an instance of ListService and calls :call" do
        allow(described_class).to receive(:new).with(controller).and_return(service_instance)
        allow(service_instance).to receive(:call).and_return(service_instance)

        described_class.call(controller)
        expect(service_instance).to have_received(:call)
      end
    end

    describe "#call" do
      let(:service) { described_class.new(controller) }

      it "populates options for drop down list of document categories" do
        allow(laa).to receive(:allowed_document_categories).and_return(allowed_document_categories)
        service.call
        expect(service.attachment_type_options).to eq expected_attachment_type_options
      end
    end

    it_behaves_like "An uploaded evidence service"
  end
end
