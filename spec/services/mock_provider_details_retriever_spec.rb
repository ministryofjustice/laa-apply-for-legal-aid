require 'rails_helper'

RSpec.describe MockProviderDetailsRetriever do
  context 'a mock user is logged in' do
    let(:username) { 'Faker::Internet.username' }
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
    end
  end

  context 'CCMS user NEETADESOR is logged in' do
    let(:username) { 'NEETADESOR' }
    let(:contact_name) { username.snakecase.titlecase }

    subject { described_class.call(username) }

    describe '.call' do
      it 'returns the expected data structure' do
        expected_keys = %i[providerOffices contactId contactName]
        expect(subject.keys).to match_array(expected_keys)
        expect(subject[:contactId]).to eq '2016472'
        expect(subject[:providerOffices][0][:officeName]).to eq 'Desor & Co._81693'
      end
    end
  end

  context 'CCMS user DAVIDGRAYLLPTWO is logged in' do
    let(:username) { 'DAVIDGRAYLLPTWO' }
    let(:contact_name) { username.snakecase.titlecase }

    subject { described_class.call(username) }

    describe '.call' do
      it 'returns the expected data structure' do
        expected_keys = %i[providerOffices contactId contactName]
        expect(subject.keys).to match_array(expected_keys)
        expect(subject[:contactId]).to eq '4953649'
        expect(subject[:providerOffices][0][:officeName]).to eq 'David Gray LLP_137570'
      end
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

  context 'CCMS user HFITZSIMONS@EDWARDHAYES.CO.UK is logged in' do
    let(:username) { 'HFITZSIMONS@EDWARDHAYES.CO.UK' }
    let(:contact_name) { username.snakecase.titlecase }

    subject { described_class.call(username) }

    describe '.call' do
      it 'returns the expected data structure' do
        expected_keys = %i[providerOffices contactId contactName]
        expect(subject.keys).to match_array(expected_keys)
        expect(subject[:contactId]).to eq '284410'
        expect(subject[:providerOffices][0][:officeName]).to eq 'Edward Hayes_137570'
      end
    end
  end
end
