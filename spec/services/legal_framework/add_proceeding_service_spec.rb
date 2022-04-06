require "rails_helper"

module LegalFramework
  RSpec.describe AddProceedingService, :vcr do
    subject { described_class.new(legal_aid_application) }

    let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
    let(:ccms_code) { "DA004" }

    describe "#call" do
      context "correct params" do
        let(:params) do
          {
            ccms_code: ccms_code,
          }
        end

        it "adds a proceeding" do
          expect { subject.call(**params) }.to change { legal_aid_application.proceedings.count }.by(1)
        end

        context "proceedings already exist" do
          let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_proceedings }

          it "adds another proceeding type" do
            subject.call(**params)
            expect(legal_aid_application.proceedings.count).to eq 2
          end
        end

        it "calls LeadProceedingAssignmentService" do
          expect(LeadProceedingAssignmentService).to receive(:call).with(legal_aid_application)
          subject.call(**params)
        end
      end

      context "on failure" do
        let(:params) do
          {
            ccms_code: nil,
          }
        end

        it "returns false" do
          expect(subject.call(**params)).to eq false
        end

        it "does not call LeadProceedingAssignmentService" do
          expect(LeadProceedingAssignmentService).not_to receive(:call).with(legal_aid_application)
          subject.call(**params)
        end
      end
    end
  end
end
