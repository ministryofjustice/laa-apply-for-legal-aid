require "rails_helper"

RSpec.describe "POST /v1/dismiss_announcements_controller" do
  subject(:post_request) { post v1_dismiss_announcements_path(announcement), params: }

  let(:announcement) { Announcement.create!(display_type: :moj, body: "Fake news!", start_at: Time.zone.local(2025, 11, 1, 9, 0), end_at: Time.zone.local(2025, 12, 1, 9, 0)) }
  let(:provider) { create(:provider) }
  let(:params) do
    {
      id: announcement.id,
      return_to: in_progress_providers_legal_aid_applications_path(provider),
    }
  end

  before { login_as provider }

  it "creates a new provider_dismissed_announcement" do
    expect { post_request }.to change(ProviderDismissedAnnouncement, :count).from(0).to(1)
  end
end
