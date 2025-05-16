require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::ApplicantsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq new_providers_applicant_path }
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :has_national_insurance_numbers }
  end
end
