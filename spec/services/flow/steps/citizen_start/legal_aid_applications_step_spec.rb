require "rails_helper"

RSpec.describe Flow::Steps::CitizenStart::LegalAidApplicationsStep, type: :request do
  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :consents }
  end
end
