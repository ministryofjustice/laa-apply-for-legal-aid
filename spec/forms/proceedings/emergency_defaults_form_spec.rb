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
           substantive_level_of_service: nil,
           substantive_level_of_service_name: nil,
           substantive_level_of_service_stage: nil,
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
            hearing_date: nil,
          }
        end

        it { is_expected.to be false }

        it "returns the expected error messages" do
          form_valid?
          expect(form.errors.messages).to eql({ hearing_date: ["Enter a valid hearing date"] })
        end
      end

      context "when the user accepts the defaults but additional input is incomplete/invalid" do
        let(:params) do
          {
            accepted_emergency_defaults: true,
            emergency_level_of_service: 3,
            emergency_level_of_service_name: "Full Representation",
            emergency_level_of_service_stage: 8,
            additional_params: { name: "hearing_date" },
            hearing_date: Time.zone.today.year.to_s,
          }
        end

        it { is_expected.to be false }

        it "returns the expected error messages" do
          form_valid?
          expect(form.errors.messages).to eql({ hearing_date: ["Enter a valid hearing date"] })
        end
      end

      context "when the user accepts the defaults and additional input is complete/valid" do
        let(:params) do
          {
            accepted_emergency_defaults: true,
            emergency_level_of_service: 3,
            emergency_level_of_service_name: "Full Representation",
            emergency_level_of_service_stage: 8,
            additional_params: { name: "hearing_date" },
            hearing_date: Time.zone.today.to_date.to_s(:date_picker),
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
          expect { save_form }.to change(proceeding, :accepted_emergency_defaults).from(nil).to(true)
        end

        it "sets the default values" do
          expect { save_form }.to change { proceeding.reload.attributes.symbolize_keys }
            .from(
              hash_including(
                {
                  emergency_level_of_service: nil,
                  emergency_level_of_service_name: nil,
                  emergency_level_of_service_stage: nil,
                },
              ),
            ).to(
              hash_including(
                {
                  emergency_level_of_service: 3,
                  emergency_level_of_service_name: "Full Representation",
                  emergency_level_of_service_stage: 8,
                },
              ),
            )
        end

        context "when the default is submitted with a hearing date" do
          let(:params) do
            {
              accepted_emergency_defaults: true,
              emergency_level_of_service: 3,
              emergency_level_of_service_name: "Full Representation",
              emergency_level_of_service_stage: 8,
              hearing_date: Date.yesterday.to_s(:date_picker),
            }
          end

          it "creates a scope_limitation object" do
            expect { save_form }.to change(proceeding.reload.scope_limitations, :count).by(1)

            expect(proceeding.scope_limitations.find_by(scope_type: :emergency))
              .to have_attributes(code: "CV117",
                                  meaning: "Interim order inc. return date",
                                  description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                                  hearing_date: Date.yesterday)
          end
        end

        context "when the proceeding already has scope limitations" do
          before do
            proceeding.scope_limitations.create!(
              scope_type: 1,
              code: "CV118",
              meaning: "Hearing",
              description: "Limited to all steps up to and including the hearing on [see additional limitation notes]",
            )
          end

          let(:params) do
            {
              accepted_emergency_defaults: true,
              emergency_level_of_service: 3,
              emergency_level_of_service_name: "Full Representation",
              emergency_level_of_service_stage: 8,
              hearing_date: Date.yesterday.to_s(:date_picker),
            }
          end

          it "replaces the existing emergency scope limitation with a new emergency scope limitation" do
            expect(proceeding.scope_limitations.where(scope_type: :emergency).count).to eq 1

            expect { save_form }.to change { proceeding.scope_limitations.find_by(scope_type: :emergency).attributes.symbolize_keys }
              .from(
                hash_including(
                  {
                    scope_type: "emergency",
                    code: "CV118",
                    meaning: "Hearing",
                    description: "Limited to all steps up to and including the hearing on [see additional limitation notes]",
                    hearing_date: nil,
                  },
                ),
              ).to(
                hash_including(
                  {
                    scope_type: "emergency",
                    code: "CV117",
                    meaning: "Interim order inc. return date",
                    description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                    hearing_date: Date.yesterday,
                  },
                ),
              )

            expect(proceeding.scope_limitations.where(scope_type: :emergency).count).to eq 1
          end
        end
      end

      context "and the user rejects the defaults" do
        let(:accepted) { "false" }

        it "updates the accepted_emergency_defaults value" do
          expect { save_form }.to change(proceeding, :accepted_emergency_defaults).from(nil).to(false)
        end

        context "when proceeding already has emergency level of service set" do
          before do
            proceeding.update!(
              emergency_level_of_service: 3,
              emergency_level_of_service_name: "Full Representation",
              emergency_level_of_service_stage: 8,
            )
          end

          it "clears the default values" do
            expect { save_form }.to change { proceeding.reload.attributes.symbolize_keys }
            .from(
              hash_including(
                {
                  emergency_level_of_service: 3,
                  emergency_level_of_service_name: "Full Representation",
                  emergency_level_of_service_stage: 8,
                },
              ),
            ).to(
              hash_including(
                {
                  emergency_level_of_service: nil,
                  emergency_level_of_service_name: nil,
                  emergency_level_of_service_stage: nil,
                },
              ),
            )
          end
        end

        it "does not create a scope_limitation object" do
          expect { save_form }.not_to change(proceeding.reload.scope_limitations, :count)
        end
      end
    end

    context "when the user doesn't answer the question" do
      let(:accepted) { "" }

      it "is invalid" do
        expect(form).not_to be_valid
      end

      it "generates the expected error message" do
        form.validate
        expect(form.errors.map(&:attribute)).to include(:accepted_emergency_defaults)
      end

      context "without calling the subject" do
        it "does not create a scope_limitation object" do
          expect { save_form }.not_to change(proceeding.reload.scope_limitations, :count)
        end
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_form_draft) { form.save_as_draft }

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
          expect { save_form_draft }.to change(proceeding, :accepted_emergency_defaults).from(nil).to(true)
        end

        it "sets the default values" do
          expect { save_form_draft }.to change { proceeding.reload.attributes.symbolize_keys }
          .from(
            hash_including(
              {
                emergency_level_of_service: nil,
                emergency_level_of_service_name: nil,
                emergency_level_of_service_stage: nil,
              },
            ),
          ).to(
            hash_including(
              {
                emergency_level_of_service: 3,
                emergency_level_of_service_name: "Full Representation",
                emergency_level_of_service_stage: 8,
              },
            ),
          )
        end

        context "when the default is submitted with a hearing date" do
          let(:params) do
            {
              accepted_emergency_defaults: true,
              emergency_level_of_service: 3,
              emergency_level_of_service_name: "Full Representation",
              emergency_level_of_service_stage: 8,
              hearing_date: Date.yesterday.to_s(:date_picker),
            }
          end

          it "creates a scope_limitation object" do
            expect { save_form_draft }.to change(proceeding.reload.scope_limitations, :count).by(1)

            expect(proceeding.scope_limitations.find_by(scope_type: :emergency))
              .to have_attributes(code: "CV117",
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

          let(:params) do
            {
              accepted_emergency_defaults: true,
              emergency_level_of_service: 3,
              emergency_level_of_service_name: "Full Representation",
              emergency_level_of_service_stage: 8,
              hearing_date: Date.yesterday.to_s(:date_picker),
            }
          end

          it "deletes the existing emergency scope limitations and creates one new emergency scope limitation" do
            save_form_draft
            expect(proceeding.scope_limitations.where(scope_type: :emergency).count).to eq 1

            expect(proceeding.scope_limitations.find_by(scope_type: :emergency))
              .to have_attributes(code: "CV117",
                                  meaning: "Interim order inc. return date",
                                  description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                                  hearing_date: Date.yesterday)
          end
        end

        context "without calling the subject" do
          it "creates a scope_limitation object" do
            expect { save_form_draft }.to change(proceeding.reload.scope_limitations, :count).by(1)

            expect(proceeding.scope_limitations.find_by(scope_type: :emergency))
              .to have_attributes(code: "CV117",
                                  meaning: "Interim order inc. return date",
                                  description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                                  hearing_date: nil)
          end
        end
      end

      context "and the user rejects the defaults" do
        let(:accepted) { "false" }

        it "updates the accepted_emergency_defaults value" do
          expect { save_form_draft }.to change(proceeding, :accepted_emergency_defaults).from(nil).to(false)
        end

        it "clears the default values" do
          expect { save_form_draft }.to change { proceeding.reload.attributes.symbolize_keys }
          .from(
            hash_including(
              {
                emergency_level_of_service: nil,
                emergency_level_of_service_name: nil,
                emergency_level_of_service_stage: nil,
              },
            ),
          ).to(
            hash_including(
              {
                emergency_level_of_service: nil,
                emergency_level_of_service_name: nil,
                emergency_level_of_service_stage: nil,
              },
            ),
          )
        end

        context "without calling the subject" do
          it "does not create a scope_limitation object" do
            expect { save_form_draft }.not_to change(proceeding.reload.scope_limitations, :count)
          end
        end
      end
    end

    context "when the user doesn't answer the question" do
      let(:accepted) { "" }

      it "is valid" do
        save_form_draft
        expect(form).to be_valid
      end

      context "without calling the subject" do
        it "does not create a scope_limitation object" do
          expect { save_form_draft }.not_to change(proceeding.scope_limitations, :count)
        end
      end
    end
  end
end
