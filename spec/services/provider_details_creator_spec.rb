require 'rails_helper'

RSpec.describe ProviderDetailsCreator do
  let(:provider) { create :provider, name: nil }
  let(:ccms_firm) { OpenStruct.new(id: rand(1..1000), name: Faker::Company.name) }
  let(:ccms_office_1) { OpenStruct.new(id: rand(1..100), code: rand(1..100).to_s) }
  let(:ccms_office_2) { OpenStruct.new(id: rand(101..200), code: rand(101..200).to_s) }
  let(:api_response) do
    {
      providerOffices: [
        {
          providerfirmId: ccms_firm.id,
          officeId: ccms_office_1.id,
          officeName: "#{ccms_firm.name}-#{ccms_office_1.code}",
          smsVendorNum: rand(1..100),
          smsVendorSite: ccms_office_1.code
        },
        {
          providerfirmId: ccms_firm.id,
          officeId: ccms_office_2.id,
          officeName: "#{ccms_firm.name}-#{ccms_office_2.code}",
          smsVendorNum: rand(101..200),
          smsVendorSite: ccms_office_2.code
        }
      ],
      contactId: rand(1..100),
      contactName: Faker::Name.name
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
      expect { subject }.to change { provider.reload.name }.to(api_response[:contactName])
    end

    it 'updates the user_login_id of the provider' do
      expect { subject }.to change { provider.reload.user_login_id }.to(api_response[:contactId].to_s)
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
          providerOffices: [
            {
              providerfirmId: ccms_firm.id,
              officeId: ccms_office_2.id,
              officeName: "#{ccms_firm.name}-#{ccms_office_2.code}",
              smsVendorNum: rand(101..200),
              smsVendorSite: ccms_office_2.code
            },
            {
              providerfirmId: ccms_firm.id,
              officeId: ccms_office_3.id,
              officeName: "#{ccms_firm.name}-#{ccms_office_3.code}",
              smsVendorNum: rand(201..300),
              smsVendorSite: ccms_office_3.code
            }
          ],
          contactId: rand(101..200),
          contactName: Faker::Name.name
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
end
