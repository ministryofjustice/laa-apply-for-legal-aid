require "rails_helper"

RSpec.describe Providers::DiscretionaryDisregardsForm do
  subject(:form) { described_class.new(discretionary_disregards_params.merge(model: discretionary_disregards)) }

  let(:application) { create(:legal_aid_application) }
  let(:discretionary_disregards) { application.create_discretionary_disregards }
  let(:backdated_benefits) { "true" }
  let(:none_selected) { "" }
  let(:discretionary_disregards_params) do
    {
      backdated_benefits:,
      compensation_for_personal_harm: "",
      criminal_injuries_compensation: "",
      grenfell_tower_fire_victims: "",
      london_emergencies_trust: "",
      national_emergencies_trust: "",
      loss_or_harm_relating_to_this_application: "",
      victims_of_overseas_terrorism_compensation: "",
      we_love_manchester_emergency_fund: "",
      none_selected:,
    }
  end

  describe "#save" do
    subject(:call_save) { form.save }

    before { call_save }

    it "updates the application discretionary disregards" do
      expect(discretionary_disregards.backdated_benefits).to be true
      expect(discretionary_disregards.compensation_for_personal_harm).to be_nil
      expect(discretionary_disregards.criminal_injuries_compensation).to be_nil
      expect(discretionary_disregards.grenfell_tower_fire_victims).to be_nil
      expect(discretionary_disregards.london_emergencies_trust).to be_nil
      expect(discretionary_disregards.national_emergencies_trust).to be_nil
      expect(discretionary_disregards.loss_or_harm_relating_to_this_application).to be_nil
      expect(discretionary_disregards.victims_of_overseas_terrorism_compensation).to be_nil
      expect(discretionary_disregards.we_love_manchester_emergency_fund).to be_nil
    end

    context "when the form is not valid" do
      context "when none_selected not selected and nothing selected" do
        let(:backdated_benefits) { "" }

        it "is invalidt" do
          expect(form).not_to be_valid
        end

        it "adds custom blank error message" do
          error_messages = form.errors.messages.values.flatten
          expect(error_messages).to include(I18n.t("activemodel.errors.models.discretionary_disregards.attributes.base.none_selected"))
        end
      end

      context "when none_selected is true and another checkbox selected" do
        let(:none_selected) { "true" }

        it "is invalidt" do
          expect(form).not_to be_valid
        end

        it "adds custom blank error message" do
          error_messages = form.errors.messages.values.flatten
          expect(error_messages).to include(I18n.t("activemodel.errors.models.discretionary_disregards.attributes.base.none_and_another_option_selected"))
        end
      end
    end
  end

  describe "save_as_draft" do
    subject(:call_save_as_draft) { form.save_as_draft }

    before { call_save_as_draft }

    it "updates the application discretionary disregards" do
      expect(discretionary_disregards.backdated_benefits).to be true
      expect(discretionary_disregards.compensation_for_personal_harm).to be_nil
      expect(discretionary_disregards.criminal_injuries_compensation).to be_nil
      expect(discretionary_disregards.grenfell_tower_fire_victims).to be_nil
      expect(discretionary_disregards.london_emergencies_trust).to be_nil
      expect(discretionary_disregards.national_emergencies_trust).to be_nil
      expect(discretionary_disregards.loss_or_harm_relating_to_this_application).to be_nil
      expect(discretionary_disregards.victims_of_overseas_terrorism_compensation).to be_nil
      expect(discretionary_disregards.we_love_manchester_emergency_fund).to be_nil
    end

    context "when the form is not valid" do
      context "when none_selected not selected and nothing selected" do
        let(:backdated_benefits) { "" }

        it "is validt" do
          expect(form).to be_valid
        end

        it "updates the application discretionary disregards" do
          expect(discretionary_disregards.backdated_benefits).to be_nil
          expect(discretionary_disregards.compensation_for_personal_harm).to be_nil
          expect(discretionary_disregards.criminal_injuries_compensation).to be_nil
          expect(discretionary_disregards.grenfell_tower_fire_victims).to be_nil
          expect(discretionary_disregards.london_emergencies_trust).to be_nil
          expect(discretionary_disregards.national_emergencies_trust).to be_nil
          expect(discretionary_disregards.loss_or_harm_relating_to_this_application).to be_nil
          expect(discretionary_disregards.victims_of_overseas_terrorism_compensation).to be_nil
          expect(discretionary_disregards.we_love_manchester_emergency_fund).to be_nil
        end
      end

      context "when none_selected is true and another checkbox selected" do
        let(:none_selected) { "true" }

        it "is valid" do
          expect(form).to be_valid
        end

        it "updates the application discretionary disregards" do
          expect(discretionary_disregards.backdated_benefits).to be true
          expect(discretionary_disregards.compensation_for_personal_harm).to be_nil
          expect(discretionary_disregards.criminal_injuries_compensation).to be_nil
          expect(discretionary_disregards.grenfell_tower_fire_victims).to be_nil
          expect(discretionary_disregards.london_emergencies_trust).to be_nil
          expect(discretionary_disregards.national_emergencies_trust).to be_nil
          expect(discretionary_disregards.loss_or_harm_relating_to_this_application).to be_nil
          expect(discretionary_disregards.victims_of_overseas_terrorism_compensation).to be_nil
          expect(discretionary_disregards.we_love_manchester_emergency_fund).to be_nil
        end
      end
    end
  end
end
