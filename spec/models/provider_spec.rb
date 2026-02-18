require "rails_helper"

RSpec.describe Provider do
  it_behaves_like "a reauthable model"

  describe "#user_permissions" do
    context "with no permissions for provider and their firm" do
      let(:firm) { create(:firm, :with_no_permissions) }
      let(:provider) { create(:provider, :with_no_permissions, firm:) }

      it "returns empty array" do
        expect(provider.user_permissions).to be_empty
      end
    end

    context "with permission for provider but not firm" do
      let(:firm) { create(:firm, :with_no_permissions) }
      let(:provider) { create(:provider, :with_dummy_permission, firm:) }

      it "returns the providers permission" do
        expect(provider.user_permissions).to be_a(ActiveRecord::Relation)
        expect(provider.user_permissions.first).to be(provider.permissions.first)
      end
    end

    context "with permission for firm but not provider" do
      let(:firm) { create(:firm, :with_dummy_permission) }
      let(:provider) { create(:provider, :with_no_permissions, firm:) }

      it "returns the firms permission" do
        expect(provider.user_permissions).to be_a(ActiveRecord::Relation)
        expect(provider.user_permissions.first).to be(firm.permissions.first)
      end
    end
  end

  describe ".from_omniauth" do
    let(:auth) do
      OmniAuth::AuthHash.new(
        {
          provider: "govuk",
          uid: auth_subject_uid,
          info: {
            first_name: "first", last_name: "last", email: "provider0@example.com", description: "desc", roles: "a,b"
          },
          extra: {
            raw_info:,
          },
        },
      )
    end

    let(:raw_info) { { USER_NAME: silas_id, LAA_ACCOUNTS: "AAAAB" } }
    let(:auth_subject_uid) { SecureRandom.uuid }
    let(:silas_id) { "51cdbbb4-75d2-48d0-aaac-fa67f013c50a" }

    context "when passed a new user" do
      it "creates a new record" do
        expect { described_class.from_omniauth(auth) }.to change(described_class, :count).by(1)
      end

      it "creates the record with expected attributes" do
        provider = described_class.from_omniauth(auth)

        expect(provider).to have_attributes(
          auth_provider: "govuk",
          name: "first last",
          silas_id:,
          email: "provider0@example.com",
          office_codes: "AAAAB",
          selected_office: nil,
        )
      end
    end

    context "when passed an existing user with single office code as a string" do
      let(:raw_info) { { USER_NAME: "my-update-silas-id", LAA_ACCOUNTS: %w[BBBBB] } }

      let(:provider) do
        create(:provider,
               auth_provider: "govuk",
               email: "provider1@example.com",
               username: "CCMS_USERNAME@FIRM.COM",
               name: "Marty Ronan",
               silas_id: "my-update-silas-id",
               office_codes: "AAAAA")
      end

      it "updates the existing name" do
        expect { described_class.from_omniauth(auth) }.to change { provider.reload.name }.from("Marty Ronan").to("first last")
      end

      it "updates the existing email" do
        expect { described_class.from_omniauth(auth) }.to change { provider.reload.email }.from("provider1@example.com").to("provider0@example.com")
      end

      it "updates the existing office_codes" do
        expect { described_class.from_omniauth(auth) }.to change { provider.reload.office_codes }.from("AAAAA").to("BBBBB")
      end
    end

    context "when passed an existing user with multiple office codes as array" do
      let(:raw_info) { { USER_NAME: silas_id, LAA_ACCOUNTS: %w[AAAAA BBBBB] } }

      let(:provider) do
        create(:provider,
               auth_provider: "govuk",
               email: "provider@example.com",
               username: "CCMS_USERNAME@FIRM.COM",
               name: "Marty Ronan",
               silas_id:,
               office_codes: "00001:00002")
      end

      it "updates the existing record office_codes" do
        expect { described_class.from_omniauth(auth) }.to change { provider.reload.office_codes }.from("00001:00002").to("AAAAA:BBBBB")
      end
    end

    context "when passed an existing user with a selected office" do
      let(:provider) do
        create(:provider,
               auth_provider: "govuk",
               auth_subject_uid:,
               email: "provider@example.com",
               username: "CCMS_USERNAME@FIRM.COM",
               name: "Marty Ronan",
               silas_id:,
               office_codes: "00001:00002",
               with_office_selected: true)
      end

      it "clears the existing selected office to force reselection" do
        expect { described_class.from_omniauth(auth) }.to change { provider.reload.selected_office }.from(instance_of(Office)).to(nil)
      end
    end

    context "when data is missing from the auth payload" do
      let(:raw_info) { {} } # simulates a breakdown in entra claim enrichment

      it "logs a claim enrichment missing error" do
        allow(Rails.logger).to receive(:info)
        described_class.from_omniauth(auth)
        expect(Rails.logger).to have_received(:info).with("from_omniauth: omniauth encountered error \"Claim enrichment missing from OAuth payload\"")
      end

      it { expect(described_class.from_omniauth(auth)).to be_nil }
    end
  end

  describe "#announcements" do
    subject(:announcements) { provider.announcements }

    let(:provider) { create(:provider) }

    context "when there are multiple types of alerts" do
      before do
        Announcement.create!(display_type: :gov_uk, heading: "Big news!", start_at: Time.zone.local(2025, 11, 1, 9, 0), end_at: Time.zone.local(2025, 12, 1, 9, 0))
        Announcement.create!(display_type: :moj, body: "You won't believe this new feature", start_at: Time.zone.local(2025, 11, 11, 9, 0), end_at: Time.zone.local(2025, 12, 11, 9, 0))
      end

      it "returns all current announcements" do
        travel_to Time.zone.local(2025, 11, 20, 13, 24, 44) do
          expect(announcements.count).to eq 2
        end
      end

      context "when the provider has dismissed the feature announcement" do
        before do
          ProviderDismissedAnnouncement.create!(provider:, announcement: Announcement.find_by(body: "You won't believe this new feature"))
        end

        it "only returns the unskipped announcement" do
          travel_to Time.zone.local(2025, 11, 20, 13, 24, 44) do
            expect(announcements.count).to eq 1
          end
        end
      end
    end
  end
end
