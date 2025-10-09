require "rails_helper"

RSpec.describe LegalAidApplications::EmergencyCostOverrideForm do
  subject(:form) { described_class.new(form_params) }

  describe "validation" do
    subject(:valid?) { form.valid? }

    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_address) }
    let(:form_params) { params.merge(model: legal_aid_application) }

    context "when delegated_functions are not used" do
      subject(:valid?) { form.valid? }

      context "and the maximum substantive cost limit is below the threshold" do
        let(:params) do
          {
            substantive_cost_override: substantive_overridden,
            substantive_cost_requested: substantive_value,
            substantive_cost_reasons: substantive_reasons,
          }
        end
        let(:substantive_overridden) { "false" }
        let(:substantive_value) { nil }
        let(:substantive_reasons) { nil }

        before do
          create(:proceeding, :da006, legal_aid_application:, substantive_cost_limitation: 5_000, lead_proceeding: true, used_delegated_functions_on: nil)
          create(:proceeding, :se013, legal_aid_application:, substantive_cost_limitation: 8_000, used_delegated_functions_on: nil)
        end

        context "when no parameters sent" do
          let(:params) { {} }

          before { valid? }

          it { is_expected.to be false }

          it "displays relevant errors" do
            expect(form.errors[:substantive_cost_override]).to eq [I18n.t("activemodel.errors.models.legal_aid_application.attributes.substantive_cost_override.inclusion")]
          end
        end

        context "when the substantive_override is not requested" do
          it { is_expected.to be true }
        end

        context "when the substantive_override requested" do
          let(:substantive_overridden) { "true" }
          let(:substantive_value) { "5,000" }
          let(:substantive_reasons) { "Something, something, argument" }

          it { is_expected.to be true }

          context "but no value supplied" do
            let(:substantive_value) { nil }

            before { valid? }

            it { is_expected.to be false }

            it "displays the relevant errors" do
              expect(form.errors[:substantive_cost_requested]).to eq [I18n.t("activemodel.errors.models.legal_aid_application.attributes.substantive_cost_requested.blank")]
            end
          end

          context "but no reasons supplied" do
            let(:substantive_reasons) { nil }

            before { valid? }

            it { is_expected.to be false }

            it "displays the relevant errors" do
              expect(form.errors[:substantive_cost_reasons]).to eq [I18n.t("activemodel.errors.models.legal_aid_application.attributes.substantive_cost_reasons.blank")]
            end
          end
        end
      end

      context "and the maximum substantive cost limit is at the threshold" do
        context "when no parameters sent" do
          let(:params) { {} }

          it { is_expected.to be true }
        end
      end
    end

    context "when delegated_functions used" do
      before do
        create(:proceeding, :da001, legal_aid_application:, substantive_cost_limitation:, lead_proceeding: true, used_delegated_functions: true, used_delegated_functions_on: 35.days.ago.to_date)
        create(:proceeding, :da004, legal_aid_application:, substantive_cost_limitation: 8_000, used_delegated_functions: true, used_delegated_functions_on: 36.days.ago.to_date)
      end

      context "and the maximum substantive cost limit is below the threshold" do
        let(:substantive_cost_limitation) { 5_000 }
        let(:params) do
          {
            emergency_cost_override: emergency_overridden,
            emergency_cost_requested: emergency_value,
            emergency_cost_reasons: emergency_reasons,
            substantive_cost_override: substantive_overridden,
            substantive_cost_requested: substantive_value,
            substantive_cost_reasons: substantive_reasons,
          }
        end

        let(:emergency_overridden) { "false" }
        let(:emergency_value) { nil }
        let(:emergency_reasons) { nil }
        let(:substantive_overridden) { "false" }
        let(:substantive_value) { nil }
        let(:substantive_reasons) { nil }

        context "when no parameters sent" do
          let(:params) { {} }

          before { valid? }

          it { is_expected.to be false }

          it "displays relevant errors" do
            expect(form.errors[:emergency_cost_override]).to eq [I18n.t("activemodel.errors.models.legal_aid_application.attributes.emergency_cost_override.inclusion")]
            expect(form.errors[:substantive_cost_override]).to eq [I18n.t("activemodel.errors.models.legal_aid_application.attributes.substantive_cost_override.inclusion")]
          end
        end

        context "when the override is not requested" do
          it { is_expected.to be true }
        end

        context "when the override requested" do
          let(:emergency_overridden) { "true" }
          let(:emergency_value) { "5,000" }
          let(:emergency_reasons) { "Something, something, argument" }

          it { is_expected.to be true }

          context "but no value supplied" do
            let(:emergency_value) { nil }

            before { valid? }

            it { is_expected.to be false }

            it "displays the relevant errors" do
              expect(form.errors[:emergency_cost_requested]).to eq [I18n.t("activemodel.errors.models.legal_aid_application.attributes.emergency_cost_requested.blank")]
            end
          end

          context "but no reasons supplied" do
            let(:emergency_reasons) { nil }

            before { valid? }

            it { is_expected.to be false }

            it "displays the relevant errors" do
              expect(form.errors[:emergency_cost_reasons]).to eq [I18n.t("activemodel.errors.models.legal_aid_application.attributes.emergency_cost_reasons.blank")]
            end
          end
        end
      end

      context "and the maximum substantive cost limit is at the threshold" do
        let(:substantive_cost_limitation) { 25_000 }
        let(:params) do
          {
            emergency_cost_override: emergency_overridden,
            emergency_cost_requested: emergency_value,
            emergency_cost_reasons: emergency_reasons,
          }
        end

        let(:emergency_overridden) { "false" }
        let(:emergency_value) { nil }
        let(:emergency_reasons) { nil }

        context "when no parameters sent" do
          let(:params) { {} }

          before { valid? }

          it { is_expected.to be false }

          it "displays relevant errors" do
            expect(form.errors[:emergency_cost_override]).to eq [I18n.t("activemodel.errors.models.legal_aid_application.attributes.emergency_cost_override.inclusion")]
          end
        end

        context "when the override is not requested" do
          it { is_expected.to be true }
        end

        context "when the override requested" do
          let(:emergency_overridden) { "true" }
          let(:emergency_value) { "5,000" }
          let(:emergency_reasons) { "Something, something, argument" }

          it { is_expected.to be true }

          context "but no value supplied" do
            let(:emergency_value) { nil }

            before { valid? }

            it { is_expected.to be false }

            it "displays the relevant errors" do
              expect(form.errors[:emergency_cost_requested]).to eq [I18n.t("activemodel.errors.models.legal_aid_application.attributes.emergency_cost_requested.blank")]
            end
          end

          context "but no reasons supplied" do
            let(:emergency_reasons) { nil }

            before { valid? }

            it { is_expected.to be false }

            it "displays the relevant errors" do
              expect(form.errors[:emergency_cost_reasons]).to eq [I18n.t("activemodel.errors.models.legal_aid_application.attributes.emergency_cost_reasons.blank")]
            end
          end
        end
      end
    end
  end
end
