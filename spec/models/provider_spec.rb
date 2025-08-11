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

  describe "#cms_apply_role?" do
    let(:provider) { create(:provider, roles:) }

    before { allow(Rails.configuration.x.omniauth_entraid).to receive(:mock_auth).and_return(false) }

    context "with ccms_apply_role_present" do
      let(:roles) { "EMI,PUI_XXCCMS_BILL_PREPARATION,ZZZ,CCMS_Apply" }

      it "returns true" do
        expect(provider.ccms_apply_role?).to be true
      end
    end

    context "with ccms_apply role absent" do
      let(:roles) { "EMI,PUI_XXCCMS_BILL_PREPARATION,ZZZ" }

      it "returns true" do
        expect(provider.ccms_apply_role?).to be false
      end
    end
  end

  describe "#invalid_login?" do
    let(:provider) { create(:provider, invalid_login_details: details) }

    context "when details are nil" do
      let(:details) { nil }

      it "returns false" do
        expect(provider.invalid_login?).to be false
      end
    end

    context "when details are empty string" do
      let(:details) { "" }

      it "returns false" do
        expect(provider.invalid_login?).to be false
      end
    end

    context "when details are present" do
      let(:details) { "role" }

      it "returns true" do
        expect(provider.invalid_login?).to be true
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
            first_name: "first", last_name: "last", email: "test@test.com", description: "desc", roles: "a,b"
          },
          extra: {
            raw_info:,
          },
        },
      )
    end

    let(:raw_info) { { USER_NAME: "LEGACY@FIRM.COM", LAA_ACCOUNTS: "AAAAB" } }
    let(:auth_subject_uid) { SecureRandom.uuid }

    context "when passed a new user" do
      it "creates a new record" do
        expect { described_class.from_omniauth(auth) }.to change(described_class, :count).by(1)
      end
    end

    context "when passed an existing user with single office code as a string" do
      let(:provider) do
        described_class.create(email: "test@test.com",
                               username: "LEGACY@FIRM.COM",
                               name: "Marty Ronan",
                               auth_provider: "govuk",
                               auth_subject_uid:)
        # office codes deliberately left blank
      end

      it "updates the existing record office_codes" do
        expect { described_class.from_omniauth(auth) }.to change { provider.reload.office_codes }.from(nil).to("AAAAB")
      end
    end

    context "when passed an existing user with multiple office codes as array" do
      let(:raw_info) { { USER_NAME: "LEGACY@FIRM.COM", LAA_ACCOUNTS: %w[AAAAA BBBBB] } }

      let(:provider) do
        described_class.create(email: "test@test.com",
                               username: "LEGACY@FIRM.COM",
                               name: "Marty Ronan",
                               auth_provider: "govuk",
                               auth_subject_uid:)
        # office codes deliberately left blank
      end

      it "updates the existing record office_codes" do
        expect { described_class.from_omniauth(auth) }.to change { provider.reload.office_codes }.from(nil).to("AAAAA:BBBBB")
      end
    end

    context "when data is missing from the auth payload" do
      let(:raw_info) { {} }
      # simulates a breakdown in entra claim enrichment

      it { expect(described_class.from_omniauth(auth)).to be_nil }
    end
  end
end
