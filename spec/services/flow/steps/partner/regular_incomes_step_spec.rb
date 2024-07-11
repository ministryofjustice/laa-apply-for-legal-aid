require "rails_helper"

RSpec.describe Flow::Steps::Partner::RegularIncomesStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_partners_regular_incomes_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    before { allow(legal_aid_application).to receive(:partner_income_types?).and_return(partner_income_types) }

    context "when partner_income_types is true" do
      let(:partner_income_types) { true }

      it { is_expected.to eq :partner_cash_incomes }
    end

    context "when partner_income_types is false" do
      let(:partner_income_types) { false }

      it { is_expected.to eq :partner_student_finances }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application) }

    before { allow(legal_aid_application).to receive(:partner_income_types?).and_return(partner_income_types) }

    context "when partner_income_types is true" do
      let(:partner_income_types) { true }

      it { is_expected.to eq :partner_cash_incomes }
    end

    context "when partner_income_types is false" do
      let(:partner_income_types) { false }

      it { is_expected.to eq :check_income_answers }
    end
  end
end
