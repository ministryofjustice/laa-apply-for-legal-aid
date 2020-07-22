require 'rails_helper'

RSpec.describe MockContactIdProvider do
  context 'user is in the list of private beta users' do
    let(:provider) { create :provider, username: username, user_login_id: 7662 }

    context 'when capitalisation matches' do
      let(:username) { 'firm1-user1' }

      it 'returns the value from the file' do
        expect(described_class.call(provider)).to eq '111111'
      end
    end

    context 'when capitalisation does not match' do
      let(:username) { 'FIRM2-user1' }

      it 'returns the value from the file' do
        expect(described_class.call(provider)).to eq '222111'
      end
    end
  end

  context 'user is not in the list of private beta users' do
    let(:provider) { create :provider, username: 'test1@example.com', user_login_id: 6522 }
    it 'returns the value from the file' do
      expect(described_class.call(provider)).to eq '6522'
    end
  end
end
