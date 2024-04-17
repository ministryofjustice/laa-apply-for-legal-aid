require "rails_helper"

RSpec.describe LegalAidApplicationPolicy do
  subject(:laa_policy) { described_class.new(authorization_context, legal_aid_application) }

  let(:pre_dwp_check_controller) { Providers::CorrespondenceAddress::LookupsController.new }
  let(:post_dwp_check_controller) { Providers::BankTransactionsController.new }

  let(:controller_actions) do
    %i[
      index
      new
      show
      update
      destroy
      create
      remove_transaction_type
      continue
      reset
      show_submitted_application
    ]
  end

  context "with a Provider from another firm" do
    let(:authorization_context) { AuthorizationContext.new(provider, Providers::ProviderBaseController) }
    let(:legal_aid_application) { create(:legal_aid_application) }
    let(:provider) { create(:provider) }

    it "does not allow any action" do
      controller_actions.each do |action|
        expect(laa_policy).not_to permit(action)
      end
    end
  end

  context "with provider who created the application" do
    let(:legal_aid_application) { create(:legal_aid_application, :with_negative_benefit_check_result, provider:) }
    let(:provider) { create(:provider, :with_no_permissions) }

    context "when controller is pre-DWP check" do
      let(:authorization_context) { AuthorizationContext.new(provider, pre_dwp_check_controller) }

      it "permits all actions" do
        controller_actions.each do |action|
          expect(laa_policy).to permit(action)
        end
      end
    end

    context "when application is passported" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_positive_benefit_check_result, provider:) }
      let(:authorization_context) { AuthorizationContext.new(provider, post_dwp_check_controller) }

      it "permits all actions" do
        controller_actions.each do |action|
          expect(laa_policy).to permit(action)
        end
      end
    end

    context "when application is non-passported" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_negative_benefit_check_result, :with_non_passported_state_machine, provider:) }
      let(:authorization_context) { AuthorizationContext.new(provider, post_dwp_check_controller) }

      it "permits all actions" do
        controller_actions.each do |action|
          expect(laa_policy).to permit(action)
        end
      end
    end
  end
end
