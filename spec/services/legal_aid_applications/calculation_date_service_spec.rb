require "rails_helper"

RSpec.describe LegalAidApplications::CalculationDateService do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:merits_submitted_at) { Date.current }
  let(:applicant_receives_benefit) { true }
  let(:benefit_check_result) { build(:benefit_check_result, result: applicant_receives_benefit ? "yes" : "no") }

  context "with a single proceeding with delegated functions used" do
    let(:legal_aid_application) do
      create(:legal_aid_application,
             :with_proceedings,
             :with_delegated_functions_on_proceedings,
             explicit_proceedings: [:da004],
             df_options: { DA004: [used_delegated_functions_on, used_delegated_functions_reported_on] },
             transaction_period_finish_on:,
             benefit_check_result:,
             merits_submitted_at:)
    end

    let(:used_delegated_functions_on) { 1.week.ago.to_date }
    let(:used_delegated_functions_reported_on) { Date.current }
    let(:transaction_period_finish_on) { used_delegated_functions_on }

    it "returns date delegated functions were used" do
      expect(call).to eq(used_delegated_functions_on)
    end
  end

  context "with multiple proceedings with delegated functions used for each" do
    let(:legal_aid_application) do
      create(:legal_aid_application,
             :with_proceedings,
             :with_delegated_functions_on_proceedings,
             explicit_proceedings: %i[da004 se013],
             df_options: { SE013: [used_delegated_functions_on - 1.day, used_delegated_functions_reported_on],
                           DA004: [used_delegated_functions_on, used_delegated_functions_reported_on] },
             transaction_period_finish_on:,
             benefit_check_result:,
             merits_submitted_at:)
    end

    let(:used_delegated_functions_on) { 1.week.ago.to_date }
    let(:used_delegated_functions_reported_on) { Date.current }
    let(:transaction_period_finish_on) { used_delegated_functions_on }

    it "returns date earliest delegated functions were used from all proceedings" do
      expect(call).to eq(used_delegated_functions_on - 1.day)
    end
  end

  context "without delegated functions used" do
    let(:legal_aid_application) do
      create(:legal_aid_application,
             transaction_period_finish_on: Date.current,
             benefit_check_result:,
             merits_submitted_at:)
    end

    context "when applicant receives benefits" do
      let(:applicant_receives_benefit) { true }

      it "returns date of submission" do
        expect(call).to eq(merits_submitted_at)
      end
    end

    context "when applicant does not receive benefits" do
      let(:applicant_receives_benefit) { false }

      it "returns most recent date bank transactions downloaded" do
        expect(call).to eq(legal_aid_application.transaction_period_finish_on)
      end
    end
  end
end
