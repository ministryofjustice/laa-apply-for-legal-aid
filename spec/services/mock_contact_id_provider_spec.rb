require 'rails_helper'

RSpec.describe MockContactIdProvider do
  context 'user is in the list of private beta users' do
    let(:provider) { create :provider, username: 'firm1-user1', user_login_id: 7662 }
    it 'returns the value frome the file' do
      expect(described_class.call(provider)).to eq '111111'
    end
  end

  context 'user is not in the list of private beta users' do
    let(:provider) { create :provider, username: 'test1@example.com', user_login_id: 6522 }
    it 'returns the value frome the file' do
      expect(described_class.call(provider)).to eq '6522'
    end
  end
end
