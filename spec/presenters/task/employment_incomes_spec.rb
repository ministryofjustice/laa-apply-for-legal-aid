require "rails_helper"

RSpec.describe Task::EmploymentIncomes do
  subject(:instance) { described_class.new(application, name: "applicants") }

  let(:application) { create(:legal_aid_application, :with_transaction_period, applicant:, provider_received_citizen_consent:) }
  let(:applicant) { create(:applicant, employed: true) }
  let(:provider_received_citizen_consent) { nil }
  let(:bank_statement_evidence) { create(:attachment, :bank_statement, attachment_name: "bank_statement_evidence") }

  describe "#path" do
    include Rails.application.routes.url_helpers

    it "returns the route to first step of the task list item" do
      expect(instance.path).to eql providers_legal_aid_application_open_banking_consents_path(application)
    end

    context "when open banking consents is false" do
      let(:provider_received_citizen_consent) { false }

      it "returns the bank statements upload route" do
        expect(instance.path).to eql providers_legal_aid_application_bank_statements_path(application)
      end

      context "when the provider has uploaded bank statement evidence" do
        before { application.update(attachments: [bank_statement_evidence]) }

        context "when the applicant has multiple employments" do
          let(:applicant) { create(:applicant, :ida_paisley, employed: true) }

          it "returns the bank statements upload route" do
            expect(instance.path).to eql providers_legal_aid_application_means_full_employment_details_path(application)
          end
        end

        context "when the applcant has a single employment" do
          let(:applicant) { create(:applicant, :langley_yorke, employed: true) }

          before { create(:employment, legal_aid_application: application, name: "employment", owner_id: applicant.id, owner_type: applicant.class) }

          it "returns the bank statements upload route" do
            expect(instance.path).to eql providers_legal_aid_application_means_employment_income_path(application)
          end
        end

        context "when the applcant has a multiple employments" do
          let(:applicant) { create(:applicant, :ida_paisley, employed: true) }

          before do
            create(:employment, legal_aid_application: application, name: "employment 1", owner_id: applicant.id, owner_type: applicant.class)
            create(:employment, legal_aid_application: application, name: "employment 2", owner_id: applicant.id, owner_type: applicant.class)
          end

          it "returns the bank statements upload route" do
            expect(instance.path).to eql providers_legal_aid_application_means_full_employment_details_path(application)
          end
        end

        context "when the applcant has unexpected employment data from hmrc" do
          let(:applicant) { create(:applicant, :langley_yorke, employed: false, self_employed: false, armed_forces: false) }

          before { create(:employment, :with_payments_in_transaction_period, legal_aid_application: application, owner_id: applicant.id, owner_type: applicant.class) }

          it "returns the bank statements upload route" do
            expect(instance.path).to eql providers_legal_aid_application_means_unexpected_employment_income_path(application)
          end
        end

        context "when hmrc::status_analyzer returns an unexpected response" do
          let(:status_analyzer) { instance_double(HMRC::StatusAnalyzer) }

          before do
            allow(HMRC::StatusAnalyzer).to receive(:new).and_return(status_analyzer)
            allow(status_analyzer).to receive(:call).and_return(:unexpected_status)
          end

          it "raises an exception" do
            expect { instance.path }.to raise_error RuntimeError, "Unexpected hmrc status :unexpected_status"
          end
        end
      end
    end
  end
end
