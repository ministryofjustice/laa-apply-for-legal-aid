require "rails_helper"

RSpec.describe Flow::Steps::ProviderDWPOverride::CheckClientDetailsStep do
  let(:legal_aid_application) { create(:legal_aid_application) }

  it "has expected flow step" do
    expect(described_class).to have_flow_step_args(path: "/providers/applications/#{legal_aid_application.id}/check_client_details?locale=en",
                                                   forward: :received_benefit_confirmations,
                                                   check_answers: nil)
  end
end
