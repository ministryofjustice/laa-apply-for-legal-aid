require "rails_helper"

RSpec.describe Flow::Steps::DeleteStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject(:path) { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_delete_path(legal_aid_application) }
  end
end
