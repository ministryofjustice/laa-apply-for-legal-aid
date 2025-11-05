require "rails_helper"

def da001_applicant_with_df
  {
    success: true,
    requested_params: {
      proceeding_type_ccms_code: "DA001",
      delegated_functions_used: true,
      client_involvement_type: "A",
    },
    default_level_of_service: {
      level: 3,
      name: "Full Representation",
      stage: 8,
    },
    default_scope: {
      code: "CV117",
      meaning: "Interim order inc. return date",
      description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
      additional_params: [],
    },
  }.to_json
end

def da001_defendant_with_df
  {
    success: true,
    requested_params: {
      proceeding_type_ccms_code: "DA001",
      delegated_functions_used: true,
      client_involvement_type: "D",
    },
    default_level_of_service: {
      level: 3,
      name: "Full Representation",
      stage: 8,
    },
    default_scope: {
      code: "CV118",
      meaning: "Hearing",
      description: "Limited to all steps up to and including the hearing on [see additional limitation notes]",
      additional_params: [
        {
          name: "hearing_date",
          type: "date",
          mandatory: true,
        },
      ],
    },
  }.to_json
end

RSpec.describe Proceedings::EmergencyDefaultsForm, type: :form do
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
           used_delegated_functions_on: 10.days.ago,
           used_delegated_functions_reported_on: Time.zone.today,
           name: "inherent_jurisdiction_high_court_injunction",
           matter_type: "Domestic Abuse",
           category_of_law: "Family",
           category_law_code: "MAT",
           ccms_matter_code: "MINJN",
           client_involvement_type_ccms_code: "A",
           client_involvement_type_description: "Applicant, claimant or petitioner",
           substantive_level_of_service: nil,
           substantive_level_of_service_name: nil,
           substantive_level_of_service_stage: nil,
           emergency_level_of_service: nil,
           emergency_level_of_service_name: nil,
           emergency_level_of_service_stage: nil)
  end

  let(:form_params) { params.merge(model: proceeding) }

  before do
    stub_request(:post, %r{#{Rails.configuration.x.legal_framework_api_host}/proceeding_type_defaults})
      .to_return(
        status: 200,
        body: default_scope_response,
        headers: { "Content-Type" => "application/json; charset=utf-8" },
      )
  end

  describe "validation" do
    let(:default_scope_response) { da001_applicant_with_df }

    context "when the user doesn't answer the question" do
      let(:params) do
        {
          accepted_emergency_defaults: "",
        }
      end

      it { is_expected.to be_invalid }
    end

    context "when the user does not accept the defaults" do
      let(:params) do
        {
          accepted_emergency_defaults: "false",
        }
      end

      it { is_expected.to be_valid }
    end

    context "when the user accepts the defaults and no additional input is required" do
      let(:params) do
        {
          accepted_emergency_defaults: "true",
        }
      end

      it { is_expected.to be_valid }
    end

    context "when hearing_date is required" do
      # let(:proceeding) { create(:proceeding, :da001, :with_cit_d, :with_df_date) }

      let(:default_scope_response) { da001_defendant_with_df }

      let(:default_params) do
        {
          accepted_emergency_defaults: "true",
          additional_params: { name: "hearing_date" },
          hearing_date: nil,
        }
      end

      context "when the user accepts the defaults and hearing date is complete/valid" do
        let(:params) do
          default_params.merge({ hearing_date: Time.zone.today.to_date.to_s(:date_picker) })
        end

        it { is_expected.to be_valid }
      end

      context "when the user accepts the defaults but hearing_date is not supplied" do
        let(:params) do
          default_params.merge({ hearing_date: nil })
        end

        it "returns the expected error messages" do
          expect(form).to be_invalid
          expect(form.errors[:hearing_date]).to include("Enter a valid hearing date")
        end
      end

      context "when the user accepts the defaults but hearing_date is using 2 digit year" do
        let(:params) do
          default_params.merge({ hearing_date: "#{Time.zone.today.day}/#{Time.zone.today.month}/#{Time.zone.today.strftime('%y').to_i}" })
        end

        it "returns the expected error messages" do
          expect(form).to be_invalid
          expect(form.errors[:hearing_date]).to include("Enter a valid hearing date in the correct format")
        end
      end

      context "when the user accepts the defaults but hearing_date is using an invalid month" do
        let(:params) do
          default_params.merge({ hearing_date: "#{Time.zone.today.day}/13/#{Time.zone.today.year}" })
        end

        it "returns the expected error messages" do
          expect(form).to be_invalid
          expect(form.errors[:hearing_date]).to include("Enter a valid hearing date in the correct format")
        end
      end

      context "when the user accepts the defaults but hearing_date is using an invalid day" do
        let(:params) do
          default_params.merge({ hearing_date: "32/#{Time.zone.today.month}/#{Time.zone.today.year}" })
        end

        it "returns the expected error messages" do
          expect(form).to be_invalid
          expect(form.errors[:hearing_date]).to include("Enter a valid hearing date in the correct format")
        end
      end
    end
  end

  describe "#save" do
    subject(:save_form) { form.save }

    context "when the submission is valid" do
      context "and the defaults are accepted (hearing_date NOT required)" do
        let(:default_scope_response) { da001_applicant_with_df }

        let(:params) do
          {
            accepted_emergency_defaults: "true",
          }
        end

        it "updates the accepted_emergency_defaults value" do
          expect { save_form }.to change(proceeding, :accepted_emergency_defaults).from(nil).to(true)
        end

        it "sets the default emergency level of service values" do
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

        it "adds the default emergency scope limitation to the proceeding" do
          expect { save_form }.to change { proceeding.scope_limitations.find_by(scope_type: :emergency)&.attributes&.symbolize_keys }
            .from(nil)
            .to(
              hash_including(
                {
                  scope_type: "emergency",
                  code: "CV117",
                  meaning: "Interim order inc. return date",
                  description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                  hearing_date: nil,
                },
              ),
            )
        end
      end

      context "and the defaults are accepted (hearing_date required)" do
        let(:default_scope_response) { da001_defendant_with_df }

        let(:params) do
          {
            accepted_emergency_defaults: "true",
            hearing_date: Date.yesterday.to_s(:date_picker),
          }
        end

        it "updates the accepted_emergency_defaults value" do
          expect { save_form }.to change(proceeding, :accepted_emergency_defaults).from(nil).to(true)
        end

        it "adds the default emergency scope limitation to the proceeding with a hearing date" do
          expect { save_form }.to change { proceeding.scope_limitations.find_by(scope_type: :emergency)&.attributes&.symbolize_keys }
            .from(nil)
            .to(
              hash_including(
                {
                  scope_type: "emergency",
                  code: "CV118",
                  meaning: "Hearing",
                  description: "Limited to all steps up to and including the hearing on [see additional limitation notes]",
                  hearing_date: Date.yesterday,
                },
              ),
            )
        end

        context "when the proceeding already has an emergency scope limitations" do
          before do
            proceeding.scope_limitations.create!(
              scope_type: 1,
              code: "CV117",
              meaning: "Interim order inc. return date",
              description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
              hearing_date: nil,
            )
          end

          let(:params) do
            {
              accepted_emergency_defaults: "true",
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
                    code: "CV117",
                    meaning: "Interim order inc. return date",
                    description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                    hearing_date: nil,
                  },
                ),
              ).to(
                hash_including(
                  {
                    scope_type: "emergency",
                    code: "CV118",
                    meaning: "Hearing",
                    description: "Limited to all steps up to and including the hearing on [see additional limitation notes]",
                    hearing_date: Date.yesterday,
                  },
                ),
              )

            expect(proceeding.scope_limitations.where(scope_type: :emergency).count).to eq 1
          end
        end
      end

      context "and the user rejects the defaults" do
        let(:params) do
          {
            accepted_emergency_defaults: "false",
          }
        end

        let(:default_scope_response) { da001_applicant_with_df }

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

          it "clears the default emergency level of service values" do
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
          expect { save_form }.not_to change(proceeding.reload.scope_limitations, :count).from(0)
        end
      end
    end

    context "when the user doesn't answer the question" do
      let(:params) do
        {
          accepted_emergency_defaults: "",
        }
      end

      let(:default_scope_response) { da001_applicant_with_df }

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
      context "and the defaults are accepted (hearing_date NOT required)" do
        let(:default_scope_response) { da001_applicant_with_df }

        let(:params) do
          {
            accepted_emergency_defaults: "true",
          }
        end

        it "updates the accepted_emergency_defaults value" do
          expect { save_form_draft }.to change(proceeding, :accepted_emergency_defaults).from(nil).to(true)
        end

        it "sets the default emergency level of service values" do
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

        it "adds the default emergency scope limitation to the proceeding" do
          expect { save_form_draft }.to change { proceeding.scope_limitations.find_by(scope_type: :emergency)&.attributes&.symbolize_keys }
            .from(nil)
            .to(
              hash_including(
                {
                  scope_type: "emergency",
                  code: "CV117",
                  meaning: "Interim order inc. return date",
                  description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                  hearing_date: nil,
                },
              ),
            )
        end
      end

      context "and the defaults are accepted (hearing_date required)" do
        let(:default_scope_response) { da001_defendant_with_df }

        let(:params) do
          {
            accepted_emergency_defaults: "true",
            hearing_date: Date.yesterday.to_s(:date_picker),
          }
        end

        it "updates the accepted_emergency_defaults value" do
          expect { save_form_draft }.to change(proceeding, :accepted_emergency_defaults).from(nil).to(true)
        end

        it "adds the default emergency scope limitation to the proceeding with a hearing date" do
          expect { save_form_draft }.to change { proceeding.scope_limitations.find_by(scope_type: :emergency)&.attributes&.symbolize_keys }
            .from(nil)
            .to(
              hash_including(
                {
                  scope_type: "emergency",
                  code: "CV118",
                  meaning: "Hearing",
                  description: "Limited to all steps up to and including the hearing on [see additional limitation notes]",
                  hearing_date: Date.yesterday,
                },
              ),
            )
        end

        context "when the proceeding already has an emergency scope limitations" do
          before do
            proceeding.scope_limitations.create!(
              scope_type: 1,
              code: "CV117",
              meaning: "Interim order inc. return date",
              description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
              hearing_date: nil,
            )
          end

          let(:params) do
            {
              accepted_emergency_defaults: "true",
              hearing_date: Date.yesterday.to_s(:date_picker),
            }
          end

          it "replaces the existing emergency scope limitation with a new emergency scope limitation" do
            expect(proceeding.scope_limitations.where(scope_type: :emergency).count).to eq 1

            expect { save_form_draft }.to change { proceeding.scope_limitations.find_by(scope_type: :emergency).attributes.symbolize_keys }
              .from(
                hash_including(
                  {
                    scope_type: "emergency",
                    code: "CV117",
                    meaning: "Interim order inc. return date",
                    description: "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
                    hearing_date: nil,
                  },
                ),
              ).to(
                hash_including(
                  {
                    scope_type: "emergency",
                    code: "CV118",
                    meaning: "Hearing",
                    description: "Limited to all steps up to and including the hearing on [see additional limitation notes]",
                    hearing_date: Date.yesterday,
                  },
                ),
              )

            expect(proceeding.scope_limitations.where(scope_type: :emergency).count).to eq 1
          end
        end
      end

      context "and the user rejects the defaults" do
        let(:params) do
          {
            accepted_emergency_defaults: "false",
          }
        end

        let(:default_scope_response) { da001_applicant_with_df }

        it "updates the accepted_emergency_defaults value" do
          expect { save_form_draft }.to change(proceeding, :accepted_emergency_defaults).from(nil).to(false)
        end

        context "when proceeding already has emergency level of service set" do
          before do
            proceeding.update!(
              emergency_level_of_service: 3,
              emergency_level_of_service_name: "Full Representation",
              emergency_level_of_service_stage: 8,
            )
          end

          it "clears the default emergency level of service values" do
            expect { save_form_draft }.to change { proceeding.reload.attributes.symbolize_keys }
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
          expect { save_form_draft }.not_to change(proceeding.reload.scope_limitations, :count).from(0)
        end
      end
    end

    context "when the user does NOT supply acceptance answer and hearing_date not required" do
      let(:params) do
        {
          accepted_emergency_defaults: "",
        }
      end

      let(:default_scope_response) { da001_applicant_with_df }

      it "is valid" do
        save_form_draft
        expect(form).to be_valid
      end

      it "does NOT create or destroy a scope_limitation object" do
        expect { save_form_draft }.not_to change(proceeding.scope_limitations, :count)
      end

      it "does NOT set the default emergency level of service values" do
        expect { save_form_draft }.not_to change { proceeding.reload.attributes.symbolize_keys }
          .from(
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

    context "when the user accepts defaults BUT hearing_date required and not supplied" do
      let(:default_scope_response) { da001_defendant_with_df }

      let(:params) do
        {
          accepted_emergency_defaults: "true",
          hearing_date: "",
        }
      end

      it "is valid" do
        save_form_draft
        expect(form).to be_valid
      end

      it "sets the default emergency level of service values" do
        expect { save_form_draft }.to change { proceeding.reload.attributes.symbolize_keys }
          .from(
            hash_including(
              {
                emergency_level_of_service: nil,
                emergency_level_of_service_name: nil,
                emergency_level_of_service_stage: nil,
              },
            ),
          )
          .to(
            hash_including(
              {
                emergency_level_of_service: 3,
                emergency_level_of_service_name: "Full Representation",
                emergency_level_of_service_stage: 8,
              },
            ),
          )
      end

      # NOTE: this tests current behaviour which, arguably, should not behave like this. Perhaps it should not create the scope limitation at all
      # but it does not matter as when continued [and valid] it will be destroyed and recreated with a valid hearing_date.
      it "adds the default emergency scope limitation to the proceeding without the hearing date" do
        expect { save_form_draft }.to change { proceeding.scope_limitations.find_by(scope_type: :emergency)&.attributes&.symbolize_keys }
          .from(nil)
          .to(
            hash_including(
              {
                scope_type: "emergency",
                code: "CV118",
                meaning: "Hearing",
                description: "Limited to all steps up to and including the hearing on [see additional limitation notes]",
                hearing_date: nil,
              },
            ),
          )
      end
    end
  end
end
