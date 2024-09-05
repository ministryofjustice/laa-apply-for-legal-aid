require "rails_helper"

RSpec.describe Proceedings::EmergencyDefaultsForm, type: :form, vcr: { cassette_name: "Proceedings_EmergencyDefaultsForm/da001_applicant_with_df" } do
  subject(:form) { described_class.new(form_params) }

  let(:proceeding) do
    create(:proceeding,
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
           emergency_level_of_service_stage: nil)
  end
  let(:params) do
    {
      accepted_emergency_defaults: accepted,
    }
  end
  let(:form_params) { params.merge(model: proceeding) }

  describe "validation" do
    subject(:form_valid?) { form.valid? }

    context "when the user doesn't answer the question" do
      let(:accepted) { "" }

      it { is_expected.to be false }
    end

    context "when the user does not accept the defaults" do
      let(:accepted) { "false" }

      it { is_expected.to be true }
    end

    context "when the user accepts the defaults and no additional input is required" do
      let(:params) do
        {
          accepted_emergency_defaults: true,
          emergency_level_of_service: 3,
          emergency_level_of_service_name: "Full Representation",
          emergency_level_of_service_stage: 8,
        }
      end

      it { is_expected.to be true }
    end

    context "when additional input is required", vcr: { cassette_name: "Proceedings_EmergencyDefaultsForm/da001_defendant_with_df" } do
      let(:proceeding) { create(:proceeding, :da001, :with_cit_d, :with_df_date) }

      context "when the user accepts the defaults but additional input not supplied" do
        let(:params) do
          {
            accepted_emergency_defaults: true,
            emergency_level_of_service: 3,
            emergency_level_of_service_name: "Full Representation",
            emergency_level_of_service_stage: 8,
            additional_params: { name: "hearing_date" },
            hearing_date_1i: nil,
            hearing_date_2i: nil,
            hearing_date_3i: nil,
          }
        end

        it { is_expected.to be false }

        it "returns the expected error messages" do
          form_valid?
          expect(form.errors.messages).to eql({ hearing_date: ["Enter a valid hearing date"] })
        end
      end

      context "when the user accepts the defaults but additional input is incomplete" do
        let(:params) do
          {
            accepted_emergency_defaults: true,
            emergency_level_of_service: 3,
            emergency_level_of_service_name: "Full Representation",
            emergency_level_of_service_stage: 8,
            additional_params: { name: "hearing_date" },
            hearing_date_1i: Time.zone.today.year,
            hearing_date_2i: nil,
            hearing_date_3i: nil,
          }
        end

        it { is_expected.to be false }

        it "returns the expected error messages" do
          form_valid?
          expect(form.errors.messages).to eql({ hearing_date: ["Enter a valid hearing date"] })
        end
      end

      context "when the user accepts the defaults and additional input is complete" do
        let(:params) do
          {
            accepted_emergency_defaults: true,
            emergency_level_of_service: 3,
            emergency_level_of_service_name: "Full Representation",
            emergency_level_of_service_stage: 8,
            additional_params: { name: "hearing_date" },
            hearing_date_1i: Time.zone.today.year,
            hearing_date_2i: Time.zone.today.month,
            hearing_date_3i: Time.zone.today.day,
          }
        end

        it { is_expected.to be true }

        it "returns no error messages" do
          form_valid?
          expect(form.errors.messages).to be_empty
        end
      end
    end
  end

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

        context "when the default is submitted with a hearing date" do
          let(:skip_subject) { true }
          let(:params) do
            {
              accepted_emergency_defaults: true,
              emergency_level_of_service: 3,
              emergency_level_of_service_name: "Full Representation",
              emergency_level_of_service_stage: 8,
              hearing_date_3i: Date.yesterday.day,
              hearing_date_2i: Date.yesterday.month,
              hearing_date_1i: Date.yesterday.year,
            }
          end

          it "creates a scope_limitation object" do
            expect { save_form }.to change(proceeding.scope_limitations, :count).by(1)
            expect(proceeding.scope_limitations.find_by(scope_type: :emergency)).to have_attributes(code: "CV117",
                                                                                                    meaning: "Interim order inc. return date",
                                                                                                    description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                                                                                                    hearing_date: Date.yesterday)
          end
        end

        context "and the proceeding already has scope limitations" do
          before do
            proceeding.scope_limitations.create!(
              scope_type: 1,
              code: "CV118",
              meaning: "Hearing",
              description: "Limited to all steps up to and including the hearing on [see additional limitation notes]",
            )
          end

          let(:skip_subject) { true }
          let(:params) do
            {
              accepted_emergency_defaults: true,
              emergency_level_of_service: 3,
              emergency_level_of_service_name: "Full Representation",
              emergency_level_of_service_stage: 8,
              hearing_date_3i: Date.yesterday.day,
              hearing_date_2i: Date.yesterday.month,
              hearing_date_1i: Date.yesterday.year,
            }
          end

          it "deletes the existing emergency scope limitations and creates one new emergency scope limitation" do
            save_form
            expect(proceeding.scope_limitations.where(scope_type: :emergency).count).to eq 1
            expect(proceeding.scope_limitations.find_by(scope_type: :emergency)).to have_attributes(code: "CV117",
                                                                                                    meaning: "Interim order inc. return date",
                                                                                                    description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                                                                                                    hearing_date: Date.yesterday)
          end
        end

        context "without calling the subject" do
          let(:skip_subject) { true }

          it "creates a scope_limitation object" do
            expect { save_form }.to change(proceeding.scope_limitations, :count).by(1)
            expect(proceeding.scope_limitations.find_by(scope_type: :emergency)).to have_attributes(code: "CV117",
                                                                                                    meaning: "Interim order inc. return date",
                                                                                                    description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                                                                                                    hearing_date: nil)
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
        expect(form).not_to be_valid
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

  describe "#save_as_draft" do
    subject(:save_form_draft) { form.save_as_draft }

    before { save_form_draft unless skip_subject }

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

        context "when the default is submitted with a hearing date" do
          let(:skip_subject) { true }
          let(:params) do
            {
              accepted_emergency_defaults: true,
              emergency_level_of_service: 3,
              emergency_level_of_service_name: "Full Representation",
              emergency_level_of_service_stage: 8,
              hearing_date_3i: Date.yesterday.day,
              hearing_date_2i: Date.yesterday.month,
              hearing_date_1i: Date.yesterday.year,
            }
          end

          it "creates a scope_limitation object" do
            expect { save_form_draft }.to change(proceeding.scope_limitations, :count).by(1)
            expect(proceeding.scope_limitations.find_by(scope_type: :emergency)).to have_attributes(code: "CV117",
                                                                                                    meaning: "Interim order inc. return date",
                                                                                                    description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                                                                                                    hearing_date: Date.yesterday)
          end
        end

        context "and the proceeding already has scope limitations" do
          before do
            proceeding.scope_limitations.create!(
              scope_type: 1,
              code: "CV118",
              meaning: "Hearing",
              description: "Limited to all steps up to and including the hearing on [see additional limitation notes]",
            )
          end

          let(:skip_subject) { true }
          let(:params) do
            {
              accepted_emergency_defaults: true,
              emergency_level_of_service: 3,
              emergency_level_of_service_name: "Full Representation",
              emergency_level_of_service_stage: 8,
              hearing_date_3i: Date.yesterday.day,
              hearing_date_2i: Date.yesterday.month,
              hearing_date_1i: Date.yesterday.year,
            }
          end

          it "deletes the existing emergency scope limitations and creates one new emergency scope limitation" do
            save_form_draft
            expect(proceeding.scope_limitations.where(scope_type: :emergency).count).to eq 1
            expect(proceeding.scope_limitations.find_by(scope_type: :emergency)).to have_attributes(code: "CV117",
                                                                                                    meaning: "Interim order inc. return date",
                                                                                                    description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                                                                                                    hearing_date: Date.yesterday)
          end
        end

        context "without calling the subject" do
          let(:skip_subject) { true }

          it "creates a scope_limitation object" do
            expect { save_form_draft }.to change(proceeding.scope_limitations, :count).by(1)
            expect(proceeding.scope_limitations.find_by(scope_type: :emergency)).to have_attributes(code: "CV117",
                                                                                                    meaning: "Interim order inc. return date",
                                                                                                    description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                                                                                                    hearing_date: nil)
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
            expect { save_form_draft }.not_to change(proceeding.scope_limitations, :count)
          end
        end
      end
    end

    context "when the user doesn't answer the question" do
      let(:accepted) { "" }

      it "is invalid" do
        expect(form).to be_valid
      end

      context "without calling the subject" do
        let(:skip_subject) { true }

        it "does not create a scope_limitation object" do
          expect { save_form_draft }.not_to change(proceeding.scope_limitations, :count)
        end
      end
    end
  end
end
