require "rails_helper"

RSpec.describe Flow::Steps::ProviderDependants::HasOtherDependantsStep, type: :request do
  let(:application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eq providers_legal_aid_application_means_has_other_dependants_path(application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(application, has_other_dependant) }

    context "when application has more than one dependant" do
      let(:has_other_dependant) { true }

      it { is_expected.to eq :dependants }
    end

    context "when application has only one dependant" do
      let(:has_other_dependant) { false }

      it { is_expected.to eq :check_income_answers }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(application, has_other_dependant) }

    context "when application has more than one dependant" do
      let(:has_other_dependant) { true }

      it { is_expected.to eq :dependants }
    end

    context "when application has only one dependant" do
      let(:has_other_dependant) { false }

      it { is_expected.to eq :check_income_answers }
    end
  end
end
