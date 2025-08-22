require "rails_helper"

RSpec.describe Provider do
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
            first_name: "first", last_name: "last", email: "provider@example.com", description: "desc", roles: "a,b"
          },
          extra: {
            raw_info:,
          },
        },
      )
    end

    let(:raw_info) { { USER_NAME: silas_id, LAA_ACCOUNTS: "AAAAB" } }
    let(:auth_subject_uid) { SecureRandom.uuid }
    let(:silas_id) { "c680f03d-48ed-4079-b3c9-ca0c97d9279d" }

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
          auth_subject_uid:,
          email: "provider@example.com",
          office_codes: "AAAAB",
        )
      end
    end

    context "when passed an existing user with single office code as a string" do
      let(:provider) do
        described_class.create(
          email: "provider@example.com",
          username: "CCMS_USERNAME@FIRM.COM",
          name: "Marty Ronan",
          auth_provider: "govuk",
          auth_subject_uid:,
          silas_id:,
          office_codes: "AAAAB:BBBBA",
        )
      end

      it "updates the existing record office_codes" do
        expect { described_class.from_omniauth(auth) }.to change { provider.reload.office_codes }.from("AAAAB:BBBBA").to("AAAAB")
      end
    end

    context "when passed an existing user with multiple office codes as array" do
      let(:raw_info) { { USER_NAME: "my-update-silas-id", LAA_ACCOUNTS: %w[AAAAA BBBBB] } }

      let(:provider) do
        described_class.create(
          email: "provider@example.com",
          username: "CCMS_USERNAME@FIRM.COM",
          name: "Marty Ronan",
          auth_provider: "govuk",
          silas_id:,
          auth_subject_uid:,
          office_codes: "00001:00002",
        )
      end

      it "updates the existing record office_codes" do
        expect { described_class.from_omniauth(auth) }.to change { provider.reload.office_codes }.from("00001:00002").to("AAAAA:BBBBB")
      end

      it "updates the existing name" do
        expect { described_class.from_omniauth(auth) }.to change { provider.reload.name }.from("Marty Ronan").to("first last")
      end

      it "updates the existing silas uuid" do
        expect { described_class.from_omniauth(auth) }
          .to change { provider.reload.silas_id }
            .from(silas_id)
            .to("my-update-silas-id")
      end
    end

    context "when data is missing from the auth payload" do
      let(:raw_info) { {} } # simulates a breakdown in entra claim enrichment

      it "logs a claim enrichment missing error" do
        allow(Rails.logger).to receive(:info)
        described_class.from_omniauth(auth)
        expect(Rails.logger).to have_received(:info).with("from_omniauth: omniauth enountered error \"Claim enrichment missing from OAuth payload\"")
      end

      it { expect(described_class.from_omniauth(auth)).to be_nil }
    end
  end
end
