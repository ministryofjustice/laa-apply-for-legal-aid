require "rails_helper"

RSpec.describe Provider do
  let(:firm) { create(:firm) }
  let(:provider) { create(:provider, firm:) }

  describe "#update_details" do
    context "when firm exists" do
      it "does not call provider details creator immediately" do
        expect(ProviderDetailsCreator).not_to receive(:call).with(provider)
        provider.update_details
      end

      context "when staging or production" do
        before { allow(HostEnv).to receive(:staging_or_production?).and_return(true) }

        it "schedules a background job" do
          expect(ProviderDetailsCreatorWorker).to receive(:perform_async).with(provider.id)
          provider.update_details
        end
      end

      context "when not staging or production" do
        before { allow(HostEnv).to receive(:staging_or_production?).and_return(false) }

        it "does not schedule a background job" do
          expect(ProviderDetailsCreatorWorker).not_to receive(:perform_async).with(provider.id)
          provider.update_details
        end
      end
    end
  end

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

    before { allow(Rails.configuration.x.laa_portal).to receive(:mock_saml).and_return(false) }

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

  describe "#newly_created_by_devise?" do
    context "with sign_in_count of 1" do
      context "with no firm" do
        let(:provider) { create(:provider, :created_by_devise) }

        it "returns true" do
          expect(provider.newly_created_by_devise?).to be true
        end
      end

      context "when firm exists" do
        let(:provider) { create(:provider, sign_in_count: 1) }

        it "returns false" do
          expect(provider.newly_created_by_devise?).to be false
        end
      end
    end

    context "with login count greater than 1" do
      let(:provider) { create(:provider, sign_in_count: 4) }

      it "returns false" do
        expect(provider.newly_created_by_devise?).to be false
      end
    end
  end
end
