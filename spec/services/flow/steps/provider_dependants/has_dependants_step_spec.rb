require "rails_helper"

RSpec.describe Flow::Steps::ProviderDependants::HasDependantsStep, type: :request do
  let(:application) { create(:legal_aid_application, has_dependants:) }
  let(:has_dependants) { true }

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eq providers_legal_aid_application_means_has_dependants_path(application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(application) }

    context "when application has dependants" do
      it { is_expected.to eq :dependants }
    end

    context "when application does not have dependants" do
      let(:has_dependants) { false }

      it { is_expected.to eq :check_income_answers }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(application) }

    context "when application has at least one dependant" do
      let(:application) { create(:legal_aid_application, :with_dependant, has_dependants: true) }

      it { is_expected.to eq :has_other_dependants }
    end

    context "when application has dependant(s) but has not yet created the dependant" do
      let(:application) { create(:legal_aid_application, has_dependants: true) }

      it { is_expected.to eq :dependants }
    end

    context "when application does not have dependants" do
      let(:application) { create(:legal_aid_application, has_dependants: false) }

      it { is_expected.to eq :check_income_answers }
    end
  end
end
