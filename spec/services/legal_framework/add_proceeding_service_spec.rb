require "rails_helper"

module LegalFramework
  RSpec.describe AddProceedingService, :vcr do
    subject(:add_proceeding_service) { described_class.new(legal_aid_application) }

    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
    let(:ccms_code) { "DA004" }

    describe "#call" do
      context "when there are correct params" do
        let(:params) do
          {
            ccms_code:,
          }
        end

        it "adds a proceeding" do
          expect { add_proceeding_service.call(**params) }.to change { legal_aid_application.proceedings.count }.by(1)
        end

        it "returns the added proceeding" do
          expect(add_proceeding_service.call(**params)).to be_a Proceeding
        end

        context "and the proceedings already exist" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_proceedings) }

          it "adds another proceeding type" do
            add_proceeding_service.call(**params)
            expect(legal_aid_application.proceedings.count).to eq 2
          end
        end

        it "calls LeadProceedingAssignmentService" do
          expect(LeadProceedingAssignmentService).to receive(:call).with(legal_aid_application)
          add_proceeding_service.call(**params)
        end

        context "when a proceeding is created" do
          before do
            add_proceeding_service.call(**params)
          end

          let(:proceeding) { legal_aid_application.proceedings.first }

          it "does not create scope_limitations" do
            expect(proceeding.reload.scope_limitations.count).to eq 0
          end

          it "does not populate the scope_limitation_attrs" do
            expect(proceeding.substantive_level_of_service).to be_nil
            expect(proceeding.substantive_level_of_service_name).to be_nil
            expect(proceeding.substantive_level_of_service_stage).to be_nil
            expect(proceeding.emergency_level_of_service).to be_nil
            expect(proceeding.emergency_level_of_service_name).to be_nil
            expect(proceeding.emergency_level_of_service_stage).to be_nil
          end
        end

        context "when adding a core SCA proceeding" do
          let(:ccms_code) { "PB004" }

          it "sets an sca_type value" do
            add_proceeding_service.call(**params)
            expect(legal_aid_application.proceedings.first.sca_type).to eq "core"
          end
        end
      end

      context "when it fails" do
        let(:params) do
          {
            ccms_code: nil,
          }
        end

        it "returns false" do
          expect(add_proceeding_service.call(**params)).to be false
        end

        it "does not call LeadProceedingAssignmentService" do
          expect(LeadProceedingAssignmentService).not_to receive(:call).with(legal_aid_application)
          add_proceeding_service.call(**params)
        end
      end
    end
  end
end
