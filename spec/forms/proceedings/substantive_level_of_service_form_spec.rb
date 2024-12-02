require "rails_helper"

RSpec.describe Proceedings::SubstantiveLevelOfServiceForm, :vcr, type: :form do
  subject(:form) { described_class.new(form_params) }

  let(:proceeding) do
    create(:proceeding,
           :se014,
           :without_df_date,
           :with_cit_z,
           substantive_level_of_service: nil,
           substantive_level_of_service_name: nil,
           substantive_level_of_service_stage: nil)
  end

  let(:params) do
    {
      substantive_level_of_service:,
    }
  end

  let(:form_params) { params.merge(model: proceeding) }

  describe "#save" do
    subject(:save_form) { form.save }

    context "when the submission is valid" do
      context "with level of service for Family Help (Higher)" do
        let(:substantive_level_of_service) { 1 }

        it "updates to the expected values" do
          expect { save_form }.to change { proceeding.reload.attributes.symbolize_keys }
            .from(
              hash_including(
                substantive_level_of_service: nil,
                substantive_level_of_service_name: nil,
                substantive_level_of_service_stage: nil,
              ),
            )
            .to(
              hash_including(
                substantive_level_of_service: 1,
                substantive_level_of_service_name: "Family Help (Higher)",
                substantive_level_of_service_stage: 1,
              ),
            )
        end
      end

      context "with level of service for Full Representation" do
        let(:substantive_level_of_service) { 3 }

        it "updates to the expected values" do
          expect { save_form }.to change { proceeding.reload.attributes.symbolize_keys }
            .from(
              hash_including(
                substantive_level_of_service: nil,
                substantive_level_of_service_name: nil,
                substantive_level_of_service_stage: nil,
              ),
            )
            .to(
              hash_including(
                substantive_level_of_service: 3,
                substantive_level_of_service_name: "Full Representation",
                substantive_level_of_service_stage: 8,
              ),
            )
        end
      end
    end

    context "when the user doesn't answer the question" do
      let(:substantive_level_of_service) { "" }

      it "is invalid" do
        expect(form).not_to be_valid
      end

      it "generates the expected error message" do
        save_form
        expect(form.errors.map(&:attribute)).to eq [:substantive_level_of_service]
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_form_draft) { form.save_as_draft }

    before { save_form_draft }

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

      it "is valid" do
        expect(form).to be_valid
      end
    end
  end
end
