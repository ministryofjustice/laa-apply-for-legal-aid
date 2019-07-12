require 'rails_helper'

RSpec.describe ProviderDetailsCreator do
  let(:provider) { create :provider }
  let(:ccms_firm) { OpenStruct.new(id: rand(1..1000), name: Faker::Company.name) }
  let(:ccms_office_1) { OpenStruct.new(id: rand(1..1000), code: rand(1..1000).to_s) }
  let(:ccms_office_2) { OpenStruct.new(id: rand(1..1000), code: rand(1..1000).to_s) }
  let(:api_response) do
    {
      providerOffices: [
        {
          providerfirmId: ccms_firm.id,
          officeId: ccms_office_1.id,
          officeName: "#{ccms_firm.name}-#{ccms_office_1.code}",
          smsVendorNum: rand(1..1000),
          smsVendorSite: ccms_office_1.code
        },
        {
          providerfirmId: ccms_firm.id,
          officeId: ccms_office_2.id,
          officeName: "#{ccms_firm.name}-#{ccms_office_2.code}",
          smsVendorNum: rand(1..1000),
          smsVendorSite: ccms_office_2.code
        }
      ],
      contactId: rand(1..1000),
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

      it 'should update the namne of the firm' do
        expect { subject }.to change { existing_firm.reload.name }.to(ccms_firm.name)
      end
    end
  end
end
