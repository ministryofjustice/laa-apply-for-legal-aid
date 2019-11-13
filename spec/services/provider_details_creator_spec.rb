require 'rails_helper'

RSpec.describe ProviderDetailsCreator do
  let(:provider) { create :provider, name: nil }
  let(:ccms_firm) { OpenStruct.new(id: rand(1..1000), name: Faker::Company.name) }
  let(:ccms_office_1) { OpenStruct.new(id: rand(1..100), code: random_vendor_code) }
  let(:ccms_office_2) { OpenStruct.new(id: rand(101..200), code: random_vendor_code) }
  let(:api_response) do
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
          id: ccms_office_1.id,
          name: "#{ccms_firm.name}-#{ccms_office_1.code}"
        },
        {
          id: ccms_office_2.id,
          name: "#{ccms_firm.name}-#{ccms_office_2.code}"
        }
      ]
    }
  end
  let(:firm) { provider.firm }
  let(:office_1) { firm.offices.find_by(ccms_id: ccms_office_1.id) }
  let(:office_2) { firm.offices.find_by(ccms_id: ccms_office_2.id) }

  before { allow(ProviderDetailsRetriever).to receive(:call).with(provider.username).and_return(api_response) }

  subject { described_class.call(provider) }

  describe '.call' do
    it 'creates the right firm' do
      expect { subject }.to change { Firm.count }.by(1)
      expect(firm.ccms_id).to eq(ccms_firm.id.to_s)
      expect(firm.name).to eq(ccms_firm.name)
    end

    it 'creates the right offices' do
      expect { subject }.to change { Office.count }.by(2)
      expect(firm.offices.count).to eq(2)
      expect(office_1.code).to eq(ccms_office_1.code)
      expect(office_2.code).to eq(ccms_office_2.code)
    end

    it 'updates the name of the provider' do
      expect { subject }.to change { provider.reload.name }.to('')
    end

    it 'updates the user_login_id of the provider' do
      expect { subject }.to change { provider.reload.user_login_id }.to(api_response[:contactUserId].to_s)
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
      let(:provider_2) { create :provider }
      let(:ccms_office_3) { OpenStruct.new(id: rand(201..300), code: rand(201..300).to_s) }
      let(:api_response_2) do
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
              id: ccms_office_2.id,
              name: "#{ccms_firm.name}-#{ccms_office_2.code}"
            },
            {
              id: ccms_office_3.id,
              name: "#{ccms_firm.name}-#{ccms_office_3.code}"
            }
          ]
        }
      end
      let(:firm) { provider.firm }
      let(:office_3) { firm.offices.find_by(ccms_id: ccms_office_3.id) }

      before do
        allow(ProviderDetailsRetriever).to receive(:call).with(provider_2.username).and_return(api_response_2)
        described_class.call(provider_2)
        subject
        provider.reload
        provider_2.reload
      end

      it 'does not add all offices to both providers' do
        expect(provider.offices).to contain_exactly(office_1, office_2)
        expect(provider_2.offices).to contain_exactly(office_2, office_3)
      end
    end
  end

  def random_vendor_code
    "#{rand(9)}#{rand(65..90).chr}#{rand(100..999)}#{rand(65..90).chr}"
  end
end
