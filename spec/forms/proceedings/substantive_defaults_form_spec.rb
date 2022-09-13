require "rails_helper"

RSpec.describe Proceedings::SubstantiveDefaultsForm, :vcr, type: :form do
  subject(:form) { described_class.new(form_params) }

  let(:proceeding) { create :proceeding, :da001, :without_df_date, :with_cit_z }
  let(:params) do
    {
      accepted_substantive_defaults: accepted,
    }
  end
  let(:form_params) { params.merge(model: proceeding) }

  describe "#save" do
    subject(:save_form) { form.save }

    before { save_form }

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
          expect(proceeding.substantive_scope_limitation_code).to eq "FM062"
          expect(proceeding.substantive_scope_limitation_meaning).to eq "Final hearing"
          expect(proceeding.substantive_scope_limitation_description).to eq "Limited to all steps up to and including final hearing and any action necessary to implement (but not enforce) the order."
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
          expect(proceeding.substantive_scope_limitation_meaning).to be_nil
          expect(proceeding.substantive_scope_limitation_description).to be_nil
          expect(proceeding.substantive_scope_limitation_code).to be_nil
        end
      end
    end

    context "when the user doesn't answer the question" do
      let(:accepted) { "" }

      it "is invalid" do
        expect(form).to be_invalid
      end

      it "generates the expected error message" do
        expect(form.errors.map(&:attribute)).to eq [:accepted_substantive_defaults]
      end
    end
  end
end
