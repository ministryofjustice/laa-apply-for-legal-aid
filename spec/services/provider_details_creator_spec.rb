require 'rails_helper'

RSpec.describe ProviderDetailsCreator do
  let(:username) { Faker::Name.name }
  let(:provider) { create :provider, name: nil, username: username }
  let(:other_provider) { create :provider, name: nil, email: Faker::Internet.safe_email }
  let(:third_provider) { create :provider, name: nil, email: nil }
  let(:ccms_firm) { OpenStruct.new(id: rand(1..1000), name: Faker::Company.name) }
  let(:ccms_office1) { OpenStruct.new(id: rand(1..100), code: random_vendor_code) }
  let(:ccms_office2) { OpenStruct.new(id: rand(101..200), code: random_vendor_code) }
  let(:contact_id) { rand(101..200) }
  let(:api_response) do
    {
      providerFirmId: ccms_firm.id,
      contactUserId: rand(101..200),
      contacts: [
        {
          id: contact_id,
          name: username
        },
        {
          id: rand(101..200),
          name: other_provider.email
        },
        {
          id: rand(101..200),
          name: third_provider.username
        }
      ],
      feeEarners: [],
      providerOffices: [
        {
          id: ccms_office1.id,
          name: "#{ccms_firm.name}-#{ccms_office1.code}"
        },
        {
          id: ccms_office2.id,
          name: "#{ccms_firm.name}-#{ccms_office2.code}"
        }
      ]
    }
  end
  let(:firm) { provider.firm }
  let(:office1) { firm.offices.find_by(ccms_id: ccms_office1.id) }
  let(:office2) { firm.offices.find_by(ccms_id: ccms_office2.id) }

  before { allow(ProviderDetailsRetriever).to receive(:call).with(provider.username).and_return(api_response) }

  subject { described_class.call(provider) }

  describe '.call' do
    it 'creates the right firm' do
      expect { subject }.to change { Firm.count }.by(1)
      expect(firm.ccms_id).to eq(ccms_firm.id.to_s)
      expect(firm.name).to eq(ccms_firm.name)
    end

    it 'adds non passported permission to the firm' do
      expect { subject }.to change { Firm.count }.by(1)
      expect(firm.permissions.map(&:role)).to match_array(['application.passported.*', 'application.non_passported.*'])
    end

    it 'creates the right offices' do
      expect { subject }.to change { Office.count }.by(2)
      expect(firm.offices.count).to eq(2)
      expect(office1.code).to eq(ccms_office1.code)
      expect(office2.code).to eq(ccms_office2.code)
    end

    it 'updates the name of the provider' do
      expect { subject }.to change { provider.reload.name }.to('')
    end

    it 'updates the contact_id of the provider' do
      expect { subject }.to change { provider.reload.contact_id }.to(contact_id)
    end

    context 'when the names match' do
      it 'updates the contact_id of the provider' do
        expect { subject }.to change { provider.reload.contact_id }.to(api_response[:contacts][0][:id])
      end
    end

    context 'when the username matches' do
      before { allow(ProviderDetailsRetriever).to receive(:call).with(third_provider.username).and_return(api_response) }

      subject { described_class.call(third_provider) }

      it 'updates the contact_id of the provider' do
        expect { subject }.to change { third_provider.reload.contact_id }.to(api_response[:contacts][2][:id])
      end
    end

    context 'when the emails match' do
      before { allow(ProviderDetailsRetriever).to receive(:call).with(third_provider.username).and_return(api_response) }

      subject { described_class.call(third_provider) }

      it 'updates the contact_id of the provider' do
        expect { subject }.to change { third_provider.reload.contact_id }.to(api_response[:contacts][2][:id])
      end
    end

    context 'selected office of provider is not returned by the API' do
      let(:selected_office) { create :office, code: 'selected-office' }
      let(:provider) { create :provider, selected_office: selected_office }

      it 'clears the selected office' do
        expect { subject }.to change { provider.reload.selected_office }.to(nil)
      end
    end

    context 'firm already exists with one of the offices' do
      let!(:existing_firm) { create :firm, ccms_id: ccms_firm.id, name: 'foobar' }
      let!(:existing_office) { create :office, firm: existing_firm }

      it 'uses existing firm' do
        expect { subject }.not_to change { Firm.count }
        expect(provider.firm_id).to eq(existing_firm.id)
      end

      it 'should add the new offices' do
        expect { subject }.to change { existing_firm.reload.offices.count }.by(2)
      end

      it 'should update the name of the firm' do
        expect { subject }.to change { existing_firm.reload.name }.to(ccms_firm.name)
      end
    end

    context 'another provider has the same firm but a different set of offices' do
      let(:provider2) { create :provider }
      let(:ccms_office3) { OpenStruct.new(id: rand(201..300), code: rand(201..300).to_s) }
      let(:api_response2) do
        {
          providerFirmId: ccms_firm.id,
          contactUserId: rand(101..200),
          contacts: [
            {
              id: rand(101..200),
              name: Faker::Name.name
            }
          ],
          providerOffices: [
            {
              id: ccms_office2.id,
              name: "#{ccms_firm.name}-#{ccms_office2.code}"
            },
            {
              id: ccms_office3.id,
              name: "#{ccms_firm.name}-#{ccms_office3.code}"
            }
          ]
        }
      end
      let(:firm) { provider.firm }
      let(:office3) { firm.offices.find_by(ccms_id: ccms_office3.id) }

      before do
        allow(ProviderDetailsRetriever).to receive(:call).with(provider2.username).and_return(api_response2)
        described_class.call(provider2)
        subject
        provider.reload
        provider2.reload
      end

      it 'does not add all offices to both providers' do
        expect(provider.offices).to contain_exactly(office1, office2)
        expect(provider2.offices).to contain_exactly(office2, office3)
      end
    end
  end

  def random_vendor_code
    "#{rand(9)}#{rand(65..90).chr}#{rand(100..999)}#{rand(65..90).chr}"
  end
end
