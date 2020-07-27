require 'rails_helper'

RSpec.describe MockProviderDetailsRetriever do
  let(:expected_keys) { %i[providerFirmId contactUserId contacts providerOffices feeEarners] }

  context 'a mock user is logged in' do
    let(:username) { Faker::Internet.username }
    let(:contact_name) { "#{username.snakecase.titlecase}-1" }

    subject { described_class.call(username) }

    describe 'test1' do
      let(:username) { 'test1' }
      it 'returns the structure' do
        expect(subject.keys).to match_array(expected_keys)
      end
    end

    describe '.call' do
      it 'returns the expected data structure' do
        expect(subject[:contacts].first[:name]).to eq(contact_name)
        expect(subject.keys).to match_array(expected_keys)

        expected_office_keys = %i[id name]
        expect(subject[:providerOffices].first.keys).to match_array(expected_office_keys)

        expected_contact_keys = %i[id name]
        expect(subject[:contacts].first.keys).to match_array(expected_contact_keys)
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
        expect(subject.keys).to match_array(expected_keys)
        expect(subject[:contactUserId]).to eq 2_016_472
        expect(subject[:providerOffices].first[:name]).to eq 'DESOR & CO-0B721W'
      end
    end
  end

  context 'CCMS user MARTIN.RONAN@DAVIDGRAY.CO.UK is logged in' do
    let(:username) { 'MARTIN.RONAN@DAVIDGRAY.CO.UK' }
    let(:contact_name) { username.snakecase.titlecase }

    subject { described_class.call(username) }

    describe '.call' do
      it 'returns the expected data structure' do
        expect(subject.keys).to match_array(expected_keys)
        expect(subject[:contacts].first[:id]).to eq 34_419
        expect(subject[:providerOffices].first[:name]).to eq 'David Gray LLP-0B721W'
      end
    end

    context 'special handling for usernmes with pattern firm<n>-user<n>' do
      let(:firm1_user1) { described_class.call('firm1-user1') }
      let(:firm1_user2) { described_class.call('firm1-user2') }
      let(:firm2_user1) { described_class.call('firm2-user1') }

      it 'generates the same firm id for users in the same firm' do
        expect(firm1_user1[:providerFirmId]).to eq 805
        expect(firm1_user2[:providerFirmId]).to eq 805
      end

      it 'generates at least on office the same for both users in the same firm' do
        expect(firm1_user1[:providerOffices].first['providerfirmId']).to eq firm1_user2[:providerOffices].first['providerfirmId']
      end

      it 'generates a different firm id for users in a different firm' do
        expect(firm1_user1[:providerFirmId]).not_to eq firm2_user1[:providerFirmId]
      end
    end
  end

  context 'CCMS user HFITZSIMONS@EDWARDHAYES.CO.UK is logged in' do
    let(:username) { 'HFITZSIMONS@EDWARDHAYES.CO.UK' }
    let(:contact_name) { username.snakecase.titlecase }

    subject { described_class.call(username) }

    describe '.call' do
      it 'returns the expected data structure' do
        expect(subject.keys).to match_array(expected_keys)
        expect(subject[:providerFirmId]).to eq 20_726
        expect(subject[:contactUserId]).to eq 284_410
        expect(subject[:contacts].first[:id]).to eq 34_419
        expect(subject[:contacts].first[:name]).to eq 'Hfitzsimons@Edwardhayes Co Uk-1'
        expect(subject[:providerOffices].first[:name]).to eq 'Edward Hayes-137570'
      end
    end
  end
end
