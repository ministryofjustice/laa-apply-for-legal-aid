require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::ChangeOfNamesStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_change_of_names_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :has_other_proceedings }
  end
end
