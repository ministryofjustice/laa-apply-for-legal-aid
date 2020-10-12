require 'rails_helper'

RSpec.describe LegalAidApplicationPolicy do
  subject { LegalAidApplicationPolicy.new(authorization_context, legal_aid_application) }
  let(:pre_dwp_check_controller) { Providers::AddressLookupsController.new }
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

  context 'Provider from another firm' do
    let(:authorization_context) { AuthorizationContext.new(provider, Providers::ProviderBaseController) }
    let(:legal_aid_application) { create(:legal_aid_application) }
    let(:provider) { create(:provider) }

    it 'should not allow any action' do
      controller_actions.each do |action|
        expect(subject).not_to permit(action)
      end
    end
  end

  context 'provider who created the application' do
    let(:legal_aid_application) { create(:legal_aid_application, :with_negative_benefit_check_result, provider: provider) }
    let(:provider) { create :provider, :with_no_permissions }

    context 'controller is pre-DWP check' do
      let(:authorization_context) { AuthorizationContext.new(provider, pre_dwp_check_controller) }
      it 'should permit all actions' do
        controller_actions.each do |action|
          expect(subject).to permit(action)
        end
      end
    end

    context 'application is passported' do
      let(:legal_aid_application) { create(:legal_aid_application, :with_positive_benefit_check_result, provider: provider) }
      let(:authorization_context) { AuthorizationContext.new(provider, post_dwp_check_controller) }

      context 'provider has passported rights' do
        let(:provider)  { create :provider, :with_passported_permissions }
        it 'permits all actions' do
          controller_actions.each do |action|
            expect(subject).to permit(action)
          end
        end
      end

      context 'provider does not have passported rights' do
        let(:provider)  { create :provider, :with_non_passported_permissions }
        it 'does not permit any actions' do
          controller_actions.each do |action|
            expect(subject).not_to permit(action)
          end
        end
      end
    end

    context 'application is non-passported' do
      let(:legal_aid_application) { create(:legal_aid_application, :with_negative_benefit_check_result, :with_non_passported_state_machine, provider: provider) }
      let(:authorization_context) { AuthorizationContext.new(provider, post_dwp_check_controller) }
      context 'provider has non-passported rights' do
        let(:provider) { create :provider, :with_non_passported_permissions }

        it 'permits all actions' do
          controller_actions.each do |action|
            expect(subject).to permit(action)
          end
        end
      end

      context 'provider does not have non-passported rights' do
        let(:provider) { create :provider, :with_passported_permissions }
        it 'does not permit any actions' do
          controller_actions.each do |action|
            expect(subject).not_to permit(action)
          end
        end
      end
    end
  end
end
