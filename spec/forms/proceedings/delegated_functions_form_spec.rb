require "rails_helper"

RSpec.describe Proceedings::DelegatedFunctionsForm, type: :form do
  subject(:df_form) { described_class.new(form_params) }

  let(:proceeding) { create(:proceeding, :da001) }
  let(:params) do
    {
      used_delegated_functions: used_df?,
      used_delegated_functions_on_3i: df_date&.day&.to_s,
      used_delegated_functions_on_2i: df_date&.month&.to_s,
      used_delegated_functions_on_1i: df_date&.year&.to_s,
    }
  end
  let(:form_params) { params.merge(model: proceeding) }

  describe "#save" do
    subject(:save_form) { df_form.save }

    before { save_form }

    context "when the parameters are valid" do
      let(:used_df?) { true }
      let(:df_date) { Time.zone.yesterday }

      it "updates the proceeding" do
        expect(proceeding.reload.used_delegated_functions).to be true
        expect(proceeding.reload.used_delegated_functions_on).to eq Time.zone.yesterday
        expect(proceeding.reload.used_delegated_functions_reported_on).to eq Time.zone.today
      end
    end

    context "when provider changes yes to no" do
      let(:proceeding) { create(:proceeding, :da002) }
      let(:params) do
        {
          used_delegated_functions: false,
        }
      end

      it "updates the proceeding to remove the previous values" do
        expect(proceeding.reload.used_delegated_functions).to be false
        expect(proceeding.reload.used_delegated_functions_on).to be_nil
        expect(proceeding.reload.used_delegated_functions_reported_on).to be_nil
      end
    end

    context "when the user selects nothing" do
      let(:used_df?) { nil }
      let(:df_date) { nil }

      it "is invalid" do
        expect(df_form).not_to be_valid
      end

      it "generates the expected error message" do
        message = I18n.t("activemodel.errors.models.proceedings.attributes.used_delegated_functions.blank")
        expect(df_form.errors[:used_delegated_functions]).to include(message)
      end
    end

    context "with invalid params" do
      context "when the date is in the future" do
        let(:used_df?) { true }
        let(:df_date) { Time.zone.tomorrow }

        it "is invalid" do
          expect(df_form).not_to be_valid
        end

        it "generates the expected error message" do
          message = I18n.t("activemodel.errors.models.proceedings.attributes.used_delegated_functions_on.date_is_in_the_future")
          expect(df_form.errors[:used_delegated_functions_on]).to include(message)
        end
      end

      context "when the date is partially incomplete" do
        let(:used_df?) { true }
        let(:params) do
          {
            used_delegated_functions: used_df?,
            used_delegated_functions_on_3i: Time.zone.yesterday.day.to_s,
            used_delegated_functions_on_2i: "",
            used_delegated_functions_on_1i: Time.zone.yesterday.year.to_s,
          }
        end

        it "is invalid" do
          expect(df_form).not_to be_valid
        end

        it "generates the expected error message" do
          message = I18n.t("activemodel.errors.models.proceedings.attributes.used_delegated_functions_on.date_invalid")
          expect(df_form.errors[:used_delegated_functions_on]).to include(message)
        end
      end

      context "when the date is more than a year old" do
        let(:used_df?) { true }
        let(:df_date) { Time.zone.yesterday - 13.months }

        it "is invalid" do
          expect(df_form).not_to be_valid
        end

        it "generates the expected error message" do
          message = I18n.t("activemodel.errors.models.proceedings.attributes.used_delegated_functions_on.date_not_in_range", months: Date.current.ago(12.months).strftime("%-d %B %Y"))
          expect(df_form.errors[:used_delegated_functions_on]).to include(message)
        end
      end
    end
  end

  describe "#save as draft" do
    subject(:save_form_draft) { df_form.save_as_draft }

    before { save_form_draft }

    let(:used_df?) { true }
    let(:df_date) { Time.zone.yesterday }

    it "updates each application proceeding type if they are entered" do
      expect(proceeding.reload.used_delegated_functions).to be true
      expect(proceeding.reload.used_delegated_functions_on).to eq Time.zone.yesterday
      expect(proceeding.reload.used_delegated_functions_reported_on).to eq Time.zone.today
    end

    context "when nothing selected" do
      let(:params) { {} }

      it "updates the proceedings" do
        expect(proceeding.reload.used_delegated_functions?).to be false
      end
    end

    context "when occurred on is invalid" do
      let(:used_df?) { true }
      let(:df_date) { Time.zone.yesterday - 15.months }

      it "is invalid" do
        expect(df_form).not_to be_valid
      end

      it "generates the expected error message" do
        message = I18n.t("activemodel.errors.models.proceedings.attributes.used_delegated_functions_on.date_not_in_range", months: Date.current.ago(12.months).strftime("%-d %B %Y"))
        expect(df_form.errors[:used_delegated_functions_on]).to include(message)
      end
    end

    context "when occurred on is in future" do
      let(:error_locale) { "used_delegated_functions_on.date_is_in_the_future" }
      let(:used_df?) { true }
      let(:df_date) { Time.zone.tomorrow }

      it "is invalid" do
        expect(df_form).not_to be_valid
      end

      it "generates the expected error message for the invalid proceeding date only" do
        message = I18n.t("activemodel.errors.models.proceedings.attributes.used_delegated_functions_on.date_is_in_the_future")
        expect(df_form.errors[:used_delegated_functions_on]).to include(message)
      end
    end
  end
end
