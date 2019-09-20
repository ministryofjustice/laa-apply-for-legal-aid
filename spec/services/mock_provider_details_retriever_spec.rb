require 'rails_helper'

RSpec.describe MockProviderDetailsRetriever do
  let(:username) { Faker::Internet.username }
  let(:contact_name) { username.snakecase.titlecase }

  subject { described_class.call(username) }

  describe '.call' do
    it 'returns the expected data structure' do
      expect(subject[:contactName]).to eq(contact_name)
      expected_keys = %i[providerOffices contactId contactName]
      expect(subject.keys).to match_array(expected_keys)

      expected_office_keys = %i[providerfirmId officeId officeName smsVendorNum smsVendorSite]
      expect(subject[:providerOffices][0].keys).to match_array(expected_office_keys)
    end

    it 'returns the same providerfirmId for each office' do
      expect(subject[:providerOffices].pluck(:providerfirmId).uniq.count).to eq(1)
    end

    context 'special handling for usernmes with pattern firm<n>-user<n>' do
      it 'generates the same firm id for users in the same firm' do
        firm1_user1 =  described_class.call('firm1-user1')
        firm1_user2 =  described_class.call('firm1-user2')
        expect(firm1_user1[:providerOffices].first['providerfirmId']).to eq firm1_user2[:providerOffices].first['providerfirmId']
      end

      it 'generates a different firm id for users in a different firm' do
        firm1_user1 =  described_class.call('firm1-user1')
        firm2_user1 =  described_class.call('firm2-user2')
        expect(firm1_user1[:providerOffices].first['providerfirmId']).not_to eq firm2_user1[:providerOffices].first[:providerfirmId]
      end
    end
  end
end
