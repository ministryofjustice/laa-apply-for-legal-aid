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
            ccms_code:,
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

        context "when the enable_loop feature flag" do
          before do
            allow(Setting).to receive(:enable_loop?).and_return(enable_loop)
            subject.call(**params)
          end

          let(:proceeding) { legal_aid_application.proceedings.first }

          context "is on" do
            let(:enable_loop) { true }

            it "does not populate the scope_limitation_attrs" do
              expect(proceeding.substantive_scope_limitation_code).to be_nil
              expect(proceeding.substantive_scope_limitation_meaning).to be_nil
              expect(proceeding.substantive_scope_limitation_description).to be_nil
              expect(proceeding.delegated_functions_scope_limitation_code).to be_nil
              expect(proceeding.delegated_functions_scope_limitation_meaning).to be_nil
              expect(proceeding.delegated_functions_scope_limitation_description).to be_nil
            end
          end

          context "is off" do
            let(:enable_loop) { false }

            it "populates the scope_limitation_attrs" do
              expect(proceeding.substantive_scope_limitation_code).not_to be_nil
              expect(proceeding.substantive_scope_limitation_meaning).not_to be_nil
              expect(proceeding.substantive_scope_limitation_description).not_to be_nil
              expect(proceeding.delegated_functions_scope_limitation_code).not_to be_nil
              expect(proceeding.delegated_functions_scope_limitation_meaning).not_to be_nil
              expect(proceeding.delegated_functions_scope_limitation_description).not_to be_nil
            end
          end
        end
      end

      context "on failure" do
        let(:params) do
          {
            ccms_code: nil,
          }
        end

        it "returns false" do
          expect(subject.call(**params)).to be false
        end

        it "does not call LeadProceedingAssignmentService" do
          expect(LeadProceedingAssignmentService).not_to receive(:call).with(legal_aid_application)
          subject.call(**params)
        end
      end
    end
  end
end
