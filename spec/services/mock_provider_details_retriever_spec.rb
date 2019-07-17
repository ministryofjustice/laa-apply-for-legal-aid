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
  end
end
