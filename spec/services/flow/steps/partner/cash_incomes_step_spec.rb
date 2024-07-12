require "rails_helper"

RSpec.describe Flow::Steps::Partner::CashIncomesStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_partners_cash_income_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward }

    it { is_expected.to eq :partner_student_finances }
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_income_answers }
  end
end
