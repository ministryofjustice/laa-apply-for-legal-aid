require "rails_helper"

RSpec.describe Providers::Means::CapitalDisregards::DiscretionaryForm do
  subject(:form) { described_class.new(discretionary_capital_disregards_params.merge(model: application)) }

  let(:application) { create(:legal_aid_application) }

  let(:none_selected) { "" }
  let(:discretionary_capital_disregards) { %w[backdated_benefits national_emergencies_trust] }
  let(:discretionary_capital_disregards_params) do
    {
      discretionary_capital_disregards:,
      none_selected:,
    }
  end

  describe "#save" do
    subject(:call_save) { form.save }

    before { call_save }

    it "is valid" do
      expect(form).to be_valid
    end

    it "updates the capital_discretionary_disregards" do
      expect(application.discretionary_capital_disregards.count).to eq 2
      expect(application.discretionary_capital_disregards.pluck(:mandatory)).to contain_exactly(false, false)
      expect(application.discretionary_capital_disregards.pluck(:name)).to match_array(%w[backdated_benefits national_emergencies_trust])
    end

    context "with nothing" do
      let(:none_selected) { "true" }
      let(:discretionary_capital_disregards) { nil }

      it "is valid" do
        expect(form).to be_valid
      end

      it "does not create any capital discretionary disregards" do
        expect(application.discretionary_capital_disregards.count).to eq 0
      end
    end

    context "when the form is not valid" do
      context "when none_selected not selected and nothing selected" do
        let(:discretionary_capital_disregards) { nil }

        it "is invalid" do
          expect(form).not_to be_valid
        end

        it "adds custom blank error message" do
          error_messages = form.errors.messages.values.flatten
          expect(error_messages).to include(I18n.t("activemodel.errors.models.discretionary_capital_disregards.attributes.base.none_selected"))
        end
      end

      context "when none_selected is true and another checkbox selected" do
        let(:none_selected) { "true" }

        it "is invalidt" do
          expect(form).not_to be_valid
        end

        it "adds custom blank error message" do
          error_messages = form.errors.messages.values.flatten
          expect(error_messages).to include(I18n.t("activemodel.errors.models.discretionary_capital_disregards.attributes.base.none_and_another_option_selected"))
        end
      end
    end
  end

  describe "save_as_draft" do
    subject(:call_save_as_draft) { form.save_as_draft }

    before { call_save_as_draft }

    it "is valid" do
      expect(form).to be_valid
    end

    it "updates the capital_discretionary_disregards" do
      expect(application.discretionary_capital_disregards.count).to eq 2
      expect(application.discretionary_capital_disregards.pluck(:mandatory)).to contain_exactly(false, false)
      expect(application.discretionary_capital_disregards.pluck(:name)).to match_array(%w[backdated_benefits national_emergencies_trust])
    end

    context "with nothing" do
      let(:none_selected) { "true" }
      let(:discretionary_capital_disregards) { nil }

      it "is valid" do
        expect(form).to be_valid
      end

      it "does not create any capital discretionary disregards" do
        expect(application.discretionary_capital_disregards.count).to eq 0
      end
    end

    context "when none_selected not selected and nothing selected" do
      let(:discretionary_capital_disregards) { nil }

      it "is valid" do
        expect(form).to be_valid
      end

      it "updates the capital_discretionary_disregards" do
        expect(application.discretionary_capital_disregards.count).to eq 0
      end
    end

    context "when none_selected is true and another checkbox selected" do
      let(:none_selected) { "true" }

      it "is valid" do
        expect(form).to be_valid
      end

      it "updates the capital_discretionary_disregards" do
        expect(application.discretionary_capital_disregards.count).to eq 2
        expect(application.discretionary_capital_disregards.pluck(:mandatory)).to contain_exactly(false, false)
        expect(application.discretionary_capital_disregards.pluck(:name)).to match_array(%w[backdated_benefits national_emergencies_trust])
      end
    end
  end
end
