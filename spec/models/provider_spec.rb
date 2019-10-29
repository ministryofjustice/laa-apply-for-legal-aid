require 'rails_helper'

RSpec.describe Provider, type: :model do
  let(:firm) { create :firm }
  let(:provider) { create :provider, firm: firm }

  describe '#update_details' do
    context 'firm exists' do
      it 'does not call provider details creator immediately' do
        expect(ProviderDetailsCreator).not_to receive(:call).with(provider)
        provider.update_details
      end

      it 'schedules a background job' do
        expect(ProviderDetailsCreatorWorker).to receive(:perform_async).with(provider.id)
        provider.update_details
      end
    end

    context 'firm does not exist' do
      let(:firm) { nil }

      it 'updates provider details immediately' do
        expect(ProviderDetailsCreator).to receive(:call).with(provider)
        provider.update_details
      end
    end
  end

  describe '#whitelisted_user?' do
    before do
      allow(HostEnv).to receive(:production?).and_return(true)
    end

    context 'user is whitelisted' do
      let(:provider) { create :provider, username: Rails.configuration.x.application.whitelisted_users.sample }
      it 'returns true' do
        expect(provider.whitelisted_user?).to be true
      end
    end
    context 'user is not whitelisted' do
      it 'returns false' do
        expect(provider.whitelisted_user?).to be false
      end
    end
  end
end
