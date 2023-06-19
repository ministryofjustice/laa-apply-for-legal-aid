require "rails_helper"

module CFE
  RSpec.describe SubmissionRouter do
    subject(:submission_router) { described_class.call(application) }

    let(:application) { create(:legal_aid_application) }

    before do
      allow(CFE::SubmissionManager).to receive(:call).and_return(true)
      allow(CFECivil::SubmissionBuilder).to receive(:call).and_return(true)
    end

    context "when called on production" do
      before { allow(HostEnv).to receive(:environment).and_return(:production) }

      it "will call the legacy CFE submission manager" do
        submission_router
        expect(CFECivil::SubmissionBuilder).not_to have_received(:call)
        expect(CFE::SubmissionManager).to have_received(:call).once
      end
    end

    context "when called on staging" do
      before { allow(HostEnv).to receive(:environment).and_return(:staging) }

      it "will call the new CFE Civil submission builder" do
        submission_router
        expect(CFECivil::SubmissionBuilder).to have_received(:call).once
        expect(CFE::SubmissionManager).not_to have_received(:call)
      end
    end

    context "when called on UAT" do
      before { allow(HostEnv).to receive(:environment).and_return(:uat) }

      it "will call the new CFE Civil submission builder" do
        submission_router
        expect(CFECivil::SubmissionBuilder).to have_received(:call).once
        expect(CFE::SubmissionManager).not_to have_received(:call)
      end
    end

    context "when called from local development" do
      before { allow(HostEnv).to receive(:environment).and_return(:development) }

      it "will call the new CFE Civil submission builder" do
        submission_router
        expect(CFECivil::SubmissionBuilder).to have_received(:call).once
        expect(CFE::SubmissionManager).not_to have_received(:call)
      end
    end
  end
end
