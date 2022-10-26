require "rails_helper"

RSpec.describe LegalAidApplications::CalculationDateService do
  subject { described_class.call(legal_aid_application) }

  let(:used_delegated_functions_on) { Faker::Date.backward }
  let(:transaction_period_finish_on) { Faker::Date.backward }
  let(:merits_submitted_at) { Faker::Date.backward }
  let(:applicant_receives_benefit) { Faker::Boolean.boolean }
  let(:benefit_check_result) { create(:benefit_check_result, result: applicant_receives_benefit ? "yes" : "no") }
  let(:legal_aid_application) do
    create(:legal_aid_application,
           :with_proceedings,
           :with_delegated_functions_on_proceedings,
           explicit_proceedings: [:da004],
           df_options: { DA004: [used_delegated_functions_on, used_delegated_functions_on] },
           transaction_period_finish_on:,
           benefit_check_result:,
           merits_submitted_at:)
  end

  context "delegated functions are used" do
    it "returns date delegated functions were used" do
      expect(subject).to eq(used_delegated_functions_on)
    end
  end

  context "delegated functions are not used" do
    let(:legal_aid_application) do
      create(:legal_aid_application,
             transaction_period_finish_on:,
             benefit_check_result:,
             merits_submitted_at:)
    end

    context "applicant receives benefits" do
      let(:applicant_receives_benefit) { true }

      it "returns date of submission" do
        expect(subject).to eq(merits_submitted_at)
      end
    end

    context "applicant does not receive benefits" do
      let(:applicant_receives_benefit) { false }

      it "returns most recent date bank transactions downloaded" do
        expect(subject).to eq(transaction_period_finish_on)
      end
    end
  end
end
