require "rails_helper"

RSpec.describe Flow::Steps::CitizenStart::TrueLayerStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject(:path) { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql "/auth/true_layer" }
  end
end
