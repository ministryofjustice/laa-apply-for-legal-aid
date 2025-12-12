require "rails_helper"

RSpec.describe Admin::SiteBannersController do
  let(:admin_user) { create(:admin_user) }

  before do
    sign_in admin_user
  end

  describe "GET /admin/site_banners" do
    subject(:get_request) { get admin_site_banners_path }

    it "renders successfully" do
      get_request
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Site banners")
    end

    context "when an announcement has been created" do
      before { Announcement.create(display_type: :gov_uk, heading: "Big news!", start_at: Time.zone.local(2025, 11, 1, 9, 0), end_at: Time.zone.local(2025, 12, 1, 9, 0)) }

      it "includes the message" do
        get_request
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Big news!")
      end
    end

    context "when a dismissible announcement has been created" do
      before { Announcement.create(display_type: :moj, body: "You can now create popcorn!", start_at: Time.zone.local(2025, 11, 1, 9, 0), end_at: Time.zone.local(2025, 12, 1, 9, 0)) }

      it "includes the message" do
        get_request
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("You can now create popcorn!")
        expect(response.body).to have_css("a", text: "Dismiss")
      end
    end

    context "when an announcement is currently live" do
      before { Announcement.create(display_type: :moj, body: "The movie started 5 minutes ago!", start_at: 5.minutes.ago, end_at: 5.minutes.from_now) }

      it "includes the message" do
        get_request
        expect(response.body).to have_css("strong", class: "govuk-tag", text: "Live")
      end
    end
  end

  describe "GET /admin/site_banners/new" do
    subject(:get_request) { get new_admin_site_banner_path }

    it "renders the expected page" do
      get_request
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Add announcement")
    end
  end

  describe "POST /admin/site_banners" do
    subject(:post_request) { post admin_site_banners_path, params: }

    let(:params) do
      {
        announcement: {
          display_type:,
          gov_uk_header_bar:,
          link_display:,
          link_url:,
          heading:,
          body:,
          start_at:,
          end_at:,
        },
      }
    end
    let(:display_type) { nil }
    let(:gov_uk_header_bar) { nil }
    let(:link_display) { nil }
    let(:link_url) { nil }
    let(:heading) { nil }
    let(:body) { nil }
    let(:start_at) { nil }
    let(:end_at) { nil }

    context "when there are missing params" do
      it "renders expected errors" do
        post_request
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Select a display type")
        expect(response.body).to include("Set a start date/time")
        expect(response.body).to include("Set an end date/time")
      end
    end

    context "when the minimum params are complete" do
      let(:display_type) { :gov_uk }
      let(:heading) { "A heading" }
      let(:start_at) { Time.zone.local(2025, 11, 1, 9, 0) }
      let(:end_at) { Time.zone.local(2025, 12, 1, 9, 0) }

      it "redirects to the index page" do
        post_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(admin_site_banners_path)
      end
    end

    context "when a date is invalid" do
      let(:heading) { "A heading" }
      let(:start_at) { "31/30/2025 09:10" }
      let(:end_at) { Time.zone.local(2025, 12, 1, 9, 0) }

      it "renders the page with an appropriate error" do
        post_request
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Enter a valid start date and time")
      end
    end
  end

  describe "GET /admin/site_banner/id" do
    subject(:get_request) { get admin_site_banner_path(announcement) }

    let(:announcement) { Announcement.create(display_type: :gov_uk, heading: "Big news!", start_at: Time.zone.local(2025, 11, 1, 9, 0), end_at: Time.zone.local(2025, 12, 1, 9, 0)) }

    it "renders the expected page" do
      get_request
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Announcement")
    end
  end

  describe "PATCH /admin/site_banner/id" do
    let(:announcement) { Announcement.create(display_type: :gov_uk, heading: "Big news!", start_at: Time.zone.local(2025, 11, 1, 9, 0), end_at: Time.zone.local(2025, 12, 1, 9, 0)) }

    before { patch admin_site_banner_path(announcement), params: }

    context "when the mandatory params are empty" do
      let(:params) do
        {
          announcement: {
            heading: "",
            start_at: "",
            end_at: "",
          },
        }
      end

      it "renders the expected errors" do
        expect(response.body).to include("Include, at minimum, a heading")
        expect(response.body).to include("Set a start date/time")
        expect(response.body).to include("Set an end date/time")
      end
    end

    context "when a param is updated" do
      let(:params) do
        {
          announcement: {
            heading: "Bigger news!",
            start_at: Time.zone.local(2025, 11, 1, 9, 0),
            end_at: Time.zone.local(2025, 12, 1, 9, 0),
            body: "details provided",
          },
        }
      end

      it "updates the announcement" do
        expect(response).to have_http_status(:redirect)
        expect(announcement.reload.body).to eq "details provided"
      end
    end
  end

  describe "DELETE /admin/site_banner/id" do
    subject(:delete_request) { delete admin_site_banner_path(announcement) }

    before { Announcement.create(display_type: :gov_uk, heading: "Big news!", start_at: Time.zone.local(2025, 11, 1, 9, 0), end_at: Time.zone.local(2025, 12, 1, 9, 0)) }

    let(:announcement) { Announcement.first }

    it "removes the announcement" do
      expect { delete_request }.to change(Announcement, :count).by(-1)
    end

    context "when an dismissible announcement has been created and been dismissed" do
      let(:announcement) { Announcement.create(display_type: :moj, body: "Big news!", start_at: Time.zone.local(2025, 11, 1, 9, 0), end_at: Time.zone.local(2025, 12, 1, 9, 0)) }

      before { ProviderDismissedAnnouncement.create(provider: create(:provider), announcement:) }

      it "deletes the provider_dismissed_announcement records too" do
        expect { delete_request }.to change(ProviderDismissedAnnouncement, :count).from(1).to(0)
      end
    end
  end
end
