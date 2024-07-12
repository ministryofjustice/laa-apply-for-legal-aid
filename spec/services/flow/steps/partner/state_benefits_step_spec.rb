require "rails_helper"

RSpec.describe Flow::Steps::Partner::StateBenefitsStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql new_providers_legal_aid_application_partners_state_benefit_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :partner_add_other_state_benefits }
  end
end
