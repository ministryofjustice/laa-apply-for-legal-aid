require "rails_helper"

RSpec.describe Proceedings::EmergencyDefaultsForm, :vcr, type: :form do
  subject(:form) { described_class.new(form_params) }

  let(:proceeding) do
    create :proceeding,
           lead_proceeding: true,
           ccms_code: "DA001",
           meaning: "Inherent jurisdiction high court injunction",
           description: "to be represented on an application for an injunction, order or declaration under the inherent jurisdiction of the court.",
           substantive_cost_limitation: 25_000,
           delegated_functions_cost_limitation: 5_000,
           used_delegated_functions: true,
           used_delegated_functions_on: Faker::Date.between(from: 10.days.ago, to: 2.days.ago),
           used_delegated_functions_reported_on: Time.zone.today,
           name: "inherent_jurisdiction_high_court_injunction",
           matter_type: "Domestic Abuse",
           category_of_law: "Family",
           category_law_code: "MAT",
           ccms_matter_code: "MINJN",
           client_involvement_type_ccms_code: "A",
           client_involvement_type_description: "Applicant/Claimant/Petitioner",
           emergency_level_of_service: nil,
           emergency_level_of_service_name: nil,
           emergency_level_of_service_stage: nil
  end
  let(:params) do
    {
      accepted_emergency_defaults: accepted,
    }
  end
  let(:form_params) { params.merge(model: proceeding) }

  describe "#save" do
    subject(:save_form) { form.save }

    before { save_form unless skip_subject }

    let(:skip_subject) { false }

    context "when the submission is valid" do
      context "and the user accepts the defaults" do
        let(:params) do
          {
            accepted_emergency_defaults: true,
            emergency_level_of_service: 3,
            emergency_level_of_service_name: "Full Representation",
            emergency_level_of_service_stage: 8,
          }
        end

        it "updates the accepted_emergency_defaults value" do
          expect(proceeding.reload.accepted_emergency_defaults).to be true
        end

        it "sets the default values" do
          expect(proceeding.reload.emergency_level_of_service).to eq 3
          expect(proceeding.reload.emergency_level_of_service_name).to eq "Full Representation"
          expect(proceeding.reload.emergency_level_of_service_stage).to eq 8
        end

        context "without calling the subject" do
          let(:skip_subject) { true }

          it "creates a scope_limitation object" do
            expect { save_form }.to change(proceeding.scope_limitations, :count).by(1)
            expect(proceeding.scope_limitations.find_by(scope_type: :emergency)).to have_attributes(code: "CV117",
                                                                                                    meaning: "Interim order inc. return date",
                                                                                                    description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.")
          end
        end
      end

      context "and the user rejects the defaults" do
        let(:accepted) { "false" }

        it "updates the accepted_emergency_defaults value" do
          expect(proceeding.reload.accepted_emergency_defaults).to be false
        end

        it "sets the default values" do
          expect(proceeding.reload.emergency_level_of_service).to be_nil
          expect(proceeding.reload.emergency_level_of_service_name).to be_nil
          expect(proceeding.reload.emergency_level_of_service_stage).to be_nil
        end

        context "without calling the subject" do
          let(:skip_subject) { true }

          it "does not create a scope_limitation object" do
            expect { save_form }.not_to change(proceeding.scope_limitations, :count)
          end
        end
      end
    end

    context "when the user doesn't answer the question" do
      let(:accepted) { "" }

      it "is invalid" do
        expect(form).to be_invalid
      end

      it "generates the expected error message" do
        expect(form.errors.map(&:attribute)).to eq [:accepted_emergency_defaults]
      end

      context "without calling the subject" do
        let(:skip_subject) { true }

        it "does not create a scope_limitation object" do
          expect { save_form }.not_to change(proceeding.scope_limitations, :count)
        end
      end
    end
  end
end
