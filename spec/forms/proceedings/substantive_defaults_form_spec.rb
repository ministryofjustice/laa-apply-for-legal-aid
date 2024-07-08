require "rails_helper"

RSpec.describe Proceedings::SubstantiveDefaultsForm, :vcr, type: :form do
  subject(:form) { described_class.new(form_params) }

  let(:proceeding) { create(:proceeding, :da001, :without_df_date, :with_cit_z, no_scope_limitations: true) }
  let(:params) do
    {
      accepted_substantive_defaults: accepted,
    }
  end
  let(:form_params) { params.merge(model: proceeding) }

  describe "#save" do
    subject(:save_form) { form.save }

    before { save_form unless skip_subject }

    let(:skip_subject) { false }

    context "when the submission is valid" do
      context "and the user accepts the defaults" do
        let(:accepted) { "true" }

        it "updates the accepted_substantive_defaults value" do
          expect(proceeding.reload.accepted_substantive_defaults).to be true
        end

        it "sets the default values" do
          expect(proceeding.substantive_level_of_service).to eq 3
          expect(proceeding.substantive_level_of_service_name).to eq "Full Representation"
          expect(proceeding.substantive_level_of_service_stage).to eq 8
        end

        context "without calling the subject" do
          let(:skip_subject) { true }

          it "creates a scope_limitation object" do
            expect { save_form }.to change(proceeding.scope_limitations, :count).by(1)
            expect(proceeding.scope_limitations.find_by(scope_type: :substantive)).to have_attributes(code: "AA019",
                                                                                                      meaning: "Injunction FLA-to final hearing",
                                                                                                      description: "As to proceedings under Part IV Family Law Act 1996 limited to all steps up to and including obtaining and serving a final order and in the event of breach leading to the exercise of a power of arrest to representation on the consideration of the breach by the court (but excluding applying for a warrant of arrest, if not attached, and representation in contempt proceedings).")
          end
        end

        context "when the proceeding already has scope limitations" do
          before do
            proceeding.scope_limitations.create!(
              scope_type: 0,
              code: "CV118",
              meaning: "Hearing",
              description: "Limited to all steps up to and including the hearing on [see additional limitation notes]",
            )
          end

          let(:skip_subject) { true }

          it "deletes the existing substantive scope limitations and creates one new substantive scope limitation" do
            save_form
            expect(proceeding.scope_limitations.where(scope_type: :substantive).count).to eq 1
            expect(proceeding.scope_limitations.find_by(scope_type: :substantive)).to have_attributes(code: "AA019",
                                                                                                      meaning: "Injunction FLA-to final hearing",
                                                                                                      description: "As to proceedings under Part IV Family Law Act 1996 limited to all steps up to and including obtaining and serving a final order and in the event of breach leading to the exercise of a power of arrest to representation on the consideration of the breach by the court (but excluding applying for a warrant of arrest, if not attached, and representation in contempt proceedings).")
          end
        end
      end

      context "and the user rejects the defaults" do
        let(:accepted) { "false" }

        it "updates the accepted_substantive_defaults value" do
          expect(proceeding.reload.accepted_substantive_defaults).to be false
        end

        it "sets the default values" do
          expect(proceeding.substantive_level_of_service).to be_nil
          expect(proceeding.substantive_level_of_service_name).to be_nil
          expect(proceeding.substantive_level_of_service_stage).to be_nil
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
        expect(form.errors.map(&:attribute)).to eq [:accepted_substantive_defaults]
      end

      context "without calling the subject" do
        let(:skip_subject) { true }

        it "does not create a scope_limitation object" do
          expect { save_form }.not_to change(proceeding.scope_limitations, :count)
        end
      end
    end

    context "with a Special Childrens Act proceeding" do
      let(:params) { {} }
      let(:proceeding) { create(:proceeding, :pb003, :without_df_date, client_involvement_type_ccms_code: "A", no_scope_limitations: true) }

      it "sets the default values" do
        expect(proceeding.substantive_level_of_service).to eq 3
        expect(proceeding.substantive_level_of_service_name).to eq "Full Representation"
        expect(proceeding.substantive_level_of_service_stage).to eq 8
      end

      context "without calling the subject" do
        let(:skip_subject) { true }

        it "creates a scope_limitation object" do
          expect { save_form }.to change(proceeding.scope_limitations, :count).by(1)
          expect(proceeding.scope_limitations.find_by(scope_type: :substantive)).to have_attributes(code: "FM062", description: "Limited to all steps up to and including final hearing and any action necessary to implement (but not enforce) the order.")
        end
      end
    end
  end
end
