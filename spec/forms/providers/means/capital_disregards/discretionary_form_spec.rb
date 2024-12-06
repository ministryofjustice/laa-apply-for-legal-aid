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

    context "when the form is valid" do
      it { expect(form).to be_valid }

      it "updates the capital_discretionary_disregards" do
        expect(application.discretionary_capital_disregards.count).to eq 2
        expect(application.discretionary_capital_disregards.pluck(:mandatory)).to contain_exactly(false, false)
        expect(application.discretionary_capital_disregards.pluck(:name)).to match_array(%w[backdated_benefits national_emergencies_trust])
      end

      context "with none_selected is selected and nothing else selected" do
        let(:none_selected) { "true" }
        let(:discretionary_capital_disregards) { [] }

        it { expect(form).to be_valid }

        it "does not create any capital discretionary disregards" do
          expect(application.discretionary_capital_disregards.count).to eq 0
        end
      end

      context "with an existing mandatory disregard for backdated benefits" do
        let(:mandatory_capital_disregard) { create(:capital_disregard, :mandatory, name: "backdated_benefits") }

        before { application.capital_disregards << mandatory_capital_disregard }

        it "updates the capital_discretionary_disregards" do
          expect(application.discretionary_capital_disregards.count).to eq 2
          expect(application.mandatory_capital_disregards.count).to eq 1
          expect(application.capital_disregards.pluck(:name)).to match_array(%w[backdated_benefits backdated_benefits national_emergencies_trust])
        end
      end
    end

    context "when the form is not valid" do
      context "without partner and nothing selected" do
        let(:none_selected) { "" }
        let(:discretionary_capital_disregards) { [] }

        it { expect(form).not_to be_valid }

        it "adds custom blank error message for client" do
          error_messages = form.errors.messages.values.flatten
          expect(error_messages).to include("Select if your client has received any of these payments")
        end
      end

      context "with partner and nothing selected" do
        let(:application) { create(:legal_aid_application, applicant: create(:applicant, :with_partner_with_no_contrary_interest)) }
        let(:none_selected) { "" }
        let(:discretionary_capital_disregards) { [] }

        it { expect(form).not_to be_valid }

        it "adds custom blank error message for client or partner" do
          error_messages = form.errors.messages.values.flatten
          expect(error_messages).to include("Select if your client or their partner has received any of these payments")
        end
      end

      context "without partner and none_selected plus another checkbox selected" do
        let(:none_selected) { "true" }
        let(:discretionary_capital_disregards) { %w[national_emergencies_trust] }

        it { expect(form).not_to be_valid }

        it "adds custom blank error message for client" do
          error_messages = form.errors.messages.values.flatten
          expect(error_messages).to include("Your client must either receive one or more of these payments or none")
        end
      end

      context "with partner and none_selected plus another checkbox selected" do
        let(:application) { create(:legal_aid_application, applicant: create(:applicant, :with_partner_with_no_contrary_interest)) }
        let(:none_selected) { "true" }
        let(:discretionary_capital_disregards) { %w[national_emergencies_trust] }

        it { expect(form).not_to be_valid }

        it "adds custom blank error message for client or partner" do
          error_messages = form.errors.messages.values.flatten
          expect(error_messages).to include("Your client or their partner must either receive one or more of these payments or none")
        end
      end
    end
  end

  describe "save_as_draft" do
    subject(:call_save_as_draft) { form.save_as_draft }

    before { call_save_as_draft }

    context "when the form is valid" do
      it { expect(form).to be_valid }

      it "updates the capital_discretionary_disregards" do
        expect(application.discretionary_capital_disregards.count).to eq 2
        expect(application.discretionary_capital_disregards.pluck(:mandatory)).to contain_exactly(false, false)
        expect(application.discretionary_capital_disregards.pluck(:name)).to match_array(%w[backdated_benefits national_emergencies_trust])
      end

      context "with none_selected is selected and nothing else selected" do
        let(:none_selected) { "true" }
        let(:discretionary_capital_disregards) { [] }

        it { expect(form).to be_valid }

        it "does not create any capital discretionary disregards" do
          expect(application.discretionary_capital_disregards.count).to eq 0
        end
      end
    end

    context "when none_selected not selected and nothing selected" do
      let(:discretionary_capital_disregards) { [] }

      it { expect(form).to be_valid }

      it "updates the capital_discretionary_disregards" do
        expect(application.discretionary_capital_disregards.count).to eq 0
      end
    end

    context "when none_selected is true and another checkbox selected" do
      let(:none_selected) { "true" }

      it { expect(form).to be_valid }

      it "updates the capital_discretionary_disregards" do
        expect(application.discretionary_capital_disregards.count).to eq 2
        expect(application.discretionary_capital_disregards.pluck(:mandatory)).to contain_exactly(false, false)
        expect(application.discretionary_capital_disregards.pluck(:name)).to match_array(%w[backdated_benefits national_emergencies_trust])
      end
    end
  end
end
