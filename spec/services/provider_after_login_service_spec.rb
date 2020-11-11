require 'rails_helper'

RSpec.describe ProviderAfterLoginService do
  let(:service) { described_class.new(provider) }

  subject { service.call }

  describe '.call' do
    context 'provider does not have CCMS_Apply role' do
      let(:provider) { create :provider, :created_by_devise, :without_ccms_apply_role }
      before { allow(Rails.configuration.x.laa_portal).to receive(:mock_saml).and_return(false) }

      it 'updates the provider invalid login details' do
        subject
        expect(provider.invalid_login_details).to eq 'role'
      end
    end

    context 'provider has ccms role' do
      let(:provider) { create :provider, :created_by_devise, :with_ccms_apply_role, invalid_login_details: 'provider_details_api_error' }

      context 'provider cannot be found on Provider Details API' do
        before { expect(ProviderDetailsCreator).to receive(:call).and_raise(ProviderDetailsRetriever::ApiRecordNotFoundError) }
        it 'updates the provider invalid login details' do
          subject
          expect(provider.invalid_login_details).to eq 'api_details_user_not_found'
        end
      end

      context 'provider found on Provider Details API' do
        before { expect(ProviderDetailsCreator).to receive(:call).with(provider) }
        it 'does not update invalid login details' do
          subject
          expect(provider.invalid_login_details).to be_nil
        end

        it 'clears the invalid_login_details_field' do
          subject
          expect(provider.invalid_login_details).to be_nil
        end
      end

      context 'provider details API not available' do
        before { expect(ProviderDetailsCreator).to receive(:call).and_raise(ProviderDetailsRetriever::ApiError) }
        it 'updates the provider invalid login details' do
          subject
          expect(provider.invalid_login_details).to eq 'provider_details_api_error'
        end
      end
    end
  end
end
