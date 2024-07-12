require "rails_helper"

RSpec.describe Flow::Steps::ProviderIncome::CheckIncomeAnswersStep, type: :request do
  let(:application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eql providers_legal_aid_application_means_check_income_answers_path(application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward }

    it { is_expected.to eq :capital_introductions }
  end
end
