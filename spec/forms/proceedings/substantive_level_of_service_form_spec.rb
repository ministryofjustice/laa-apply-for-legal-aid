require "rails_helper"

RSpec.describe Proceedings::SubstantiveLevelOfServiceForm, :vcr, type: :form do
  subject(:form) { described_class.new(form_params) }

  let(:proceeding) { create :proceeding, :se014, :without_df_date, :with_cit_z }
  let(:params) do
    {
      substantive_level_of_service:,
    }
  end
  let(:form_params) { params.merge(model: proceeding) }

  describe "#save" do
    subject(:save_form) { form.save }

    before { save_form }

    context "when the submission is valid" do
      context "and the user selects Family Help (Higher)" do
        let(:substantive_level_of_service) { 1 }

        it "updates the substantive_level_of_service value" do
          expect(proceeding.reload.substantive_level_of_service).to eq 1
          expect(proceeding.reload.substantive_level_of_service_name).to eq "Family Help (Higher)"
        end
      end

      context "and the user selects Full Representation" do
        let(:substantive_level_of_service) { 3 }

        it "updates the accepted_substantive_defaults value" do
          expect(proceeding.reload.substantive_level_of_service).to eq 3
          expect(proceeding.reload.substantive_level_of_service_name).to eq "Full Representation"
        end
      end
    end

    context "when the user doesn't answer the question" do
      let(:substantive_level_of_service) { "" }

      it "is invalid" do
        expect(form).to be_invalid
      end

      it "generates the expected error message" do
        expect(form.errors.map(&:attribute)).to eq [:substantive_level_of_service]
      end
    end
  end
end
