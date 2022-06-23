require "rails_helper"

RSpec.describe Provider, type: :model do
  let(:firm) { create :firm }
  let(:provider) { create :provider, firm: }

  describe "#update_details" do
    context "when firm exists" do
      it "does not call provider details creator immediately" do
        expect(ProviderDetailsCreator).not_to receive(:call).with(provider)
        provider.update_details
      end

      context "when staging or production" do
        it "schedules a background job" do
          expect(HostEnv).to receive(:staging_or_production?).and_return(true)
          expect(ProviderDetailsCreatorWorker).to receive(:perform_async).with(provider.id)
          provider.update_details
        end
      end

      context "when not staging or production" do
        it "does not schedule a background job" do
          expect(HostEnv).to receive(:staging_or_production?).and_return(false)
          expect(ProviderDetailsCreatorWorker).not_to receive(:perform_async).with(provider.id)
          provider.update_details
        end
      end
    end
  end

  describe "#user_permissions" do
    context "with no permissions for this provider, but one permission for firm" do
      let(:firm) { create :firm, :with_passported_permissions }
      let(:provider) { create :provider, :with_no_permissions, firm: }

      it "returns the firms permissions" do
        expect(provider.user_permissions).to eq [passported_permission]
      end
    end

    context "with no permissions for provider and their firm" do
      let(:firm) { create :firm, :with_no_permissions }
      let(:provider) { create :provider, :with_no_permissions, firm: }
      let(:AlertManager) { instance_double(Tracker) }

      it "returns false" do
        expect(provider.user_permissions).to be_empty
      end

      it "notifies sentry" do
        expect(AlertManager).to receive(:capture_message).with("Provider Firm has no permissions with firm id: #{firm.id}")
        provider.user_permissions
      end
    end

    context "when permissions exist for both firm and provider" do
      let(:firm) { create :firm, :with_passported_and_non_passported_permissions }
      let(:provider) { create :provider, :with_passported_permissions, firm: }

      it "returns the permission for the provider" do
        expect(provider.user_permissions).to eq [passported_permission]
        expect(provider.employment_permissions?).to be false
      end
    end

    def passported_permission
      Permission.find_by(role: "application.passported.*")
    end

    def non_passported_permission
      Permission.find_by(role: "application.non_passported.*")
    end
  end

  describe "#cms_apply_role?" do
    let(:provider) { create :provider, roles: }

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
    let(:provider) { create :provider, invalid_login_details: details }

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
        let(:provider) { create :provider, :created_by_devise }

        it "returns true" do
          expect(provider.newly_created_by_devise?).to be true
        end
      end

      context "when firm exists" do
        let(:provider) { create :provider, sign_in_count: 1 }

        it "returns false" do
          expect(provider.newly_created_by_devise?).to be false
        end
      end
    end

    context "with login count greater than 1" do
      let(:provider) { create :provider, sign_in_count: 4 }

      it "returns false" do
        expect(provider.newly_created_by_devise?).to be false
      end
    end
  end

  describe "#bank_statement_upload_permissions?" do
    context "when provider does not have bank statement upload permissions" do
      let(:provider) { create :provider, :with_no_permissions }

      it "returns false" do
        expect(provider.bank_statement_upload_permissions?).to be false
      end
    end

    context "when provider has bank statement upload permissions" do
      let(:provider) { create :provider, :with_bank_statement_upload_permissions }

      it "returns true" do
        expect(provider.bank_statement_upload_permissions?).to be true
      end
    end
  end
end
