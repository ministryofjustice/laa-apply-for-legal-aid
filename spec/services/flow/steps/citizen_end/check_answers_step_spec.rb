require "rails_helper"

RSpec.describe Flow::Steps::CitizenEnd::CheckAnswersStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq citizens_check_answers_path }
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :means_test_results }
  end
end
