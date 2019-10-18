require 'rails_helper'

RSpec.describe MapAddressLookupResults do
  subject(:service) { described_class }

  describe '#call' do
    context 'building number, street, town, city, postcode' do
      let(:result) do
        [{ 'DPA' =>
         { 'ADDRESS' => '1, BIRKS, SLAITHWAITE, HUDDERSFIELD, HD7 5UZ',
           'BUILDING_NUMBER' => '1',
           'THOROUGHFARE_NAME' => 'BIRKS',
           'DEPENDENT_LOCALITY' => 'SLAITHWAITE',
           'POST_TOWN' => 'HUDDERSFIELD',
           'POSTCODE' => 'HD7 5UZ' } }]
      end

      it 'returns the correct address' do
        address = service.call(result).first
        expect(address.address_line_one).to eq '1 BIRKS'
        expect(address.address_line_two).to eq 'SLAITHWAITE'
        expect(address.city).to eq 'HUDDERSFIELD'
        expect(address.county).to be nil
        expect(address.postcode).to eq 'HD7 5UZ'
      end
    end

    context 'building name, street, town, city, postcode' do
      let(:result) do
        [{ 'DPA' =>
         { 'ADDRESS' => 'OWLERS CLOUGH, LOWER LAUNDS, SLAITHWAITE, HUDDERSFIELD, HD7 5UZ',
           'BUILDING_NAME' => 'OWLERS CLOUGH',
           'THOROUGHFARE_NAME' => 'LOWER LAUNDS',
           'DEPENDENT_LOCALITY' => 'SLAITHWAITE',
           'POST_TOWN' => 'HUDDERSFIELD',
           'POSTCODE' => 'HD7 5UZ' } }]
      end

      it 'returns the correct address' do
        address = service.call(result).first
        expect(address.address_line_one).to eq 'OWLERS CLOUGH'
        expect(address.address_line_two).to eq 'LOWER LAUNDS'
        expect(address.city).to eq 'HUDDERSFIELD'
        expect(address.county).to be nil
        expect(address.postcode).to eq 'HD7 5UZ'
      end
    end

    context 'short building name, street, town, city, postcode' do
      let(:result) do
        [{ 'DPA' =>
         { 'ADDRESS' => '29A, MOOREND ROAD, YARDLEY GOBION, TOWCESTER, NN12 7UF',
           'BUILDING_NAME' => '29A',
           'THOROUGHFARE_NAME' => 'MOOREND ROAD',
           'DEPENDENT_LOCALITY' => 'YARDLEY GOBION',
           'POST_TOWN' => 'TOWCESTER',
           'POSTCODE' => 'NN12 7UF' } }]
      end

      it 'returns the correct address' do
        address = service.call(result).first
        expect(address.address_line_one).to eq '29A MOOREND ROAD'
        expect(address.address_line_two).to eq 'YARDLEY GOBION'
        expect(address.city).to eq 'TOWCESTER'
        expect(address.county).to be nil
        expect(address.postcode).to eq 'NN12 7UF'
      end
    end

    context 'organisation, town, city, postcode' do
      let(:result) do
        [{ 'DPA' =>
         { 'ADDRESS' => 'CHAPEL SHRED, SLAITHWAITE, HUDDERSFIELD, HD7 5UZ',
           'ORGANISATION_NAME' => 'CHAPEL SHRED',
           'DEPENDENT_LOCALITY' => 'SLAITHWAITE',
           'POST_TOWN' => 'HUDDERSFIELD',
           'POSTCODE' => 'HD7 5UZ' } }]
      end

      it 'returns the correct address' do
        address = service.call(result).first
        expect(address.address_line_one).to eq 'CHAPEL SHRED'
        expect(address.address_line_two).to eq 'SLAITHWAITE'
        expect(address.city).to eq 'HUDDERSFIELD'
        expect(address.county).to be nil
        expect(address.postcode).to eq 'HD7 5UZ'
      end
    end

    context 'organisation, building name, town, city, postcode' do
      let(:result) do
        [{ 'DPA' =>
         { 'ADDRESS' => 'GREYSTONES FARM, BRADSHAW LANE, SLAITHWAITE, HUDDERSFIELD, HD7 5UZ',
           'ORGANISATION_NAME' => 'GREYSTONES FARM',
           'BUILDING_NAME' => 'BRADSHAW LANE',
           'DEPENDENT_LOCALITY' => 'SLAITHWAITE',
           'POST_TOWN' => 'HUDDERSFIELD',
           'POSTCODE' => 'HD7 5UZ' } }]
      end

      it 'returns the correct address' do
        address = service.call(result).first
        expect(address.address_line_one).to eq 'GREYSTONES FARM'
        expect(address.address_line_two).to eq 'BRADSHAW LANE'
        expect(address.city).to eq 'HUDDERSFIELD'
        expect(address.county).to be nil
        expect(address.postcode).to eq 'HD7 5UZ'
      end
    end

    context 'organisation, building name, street, town, city, postcode' do
      let(:result) do
        [{ 'DPA' =>
         { 'ADDRESS' => 'PHILIP SUNLEY TRANSPORT LTD, LOWER LAUND FARM, LOWER LAUNDS, SLAITHWAITE, HUDDERSFIELD, HD7 5UZ',
           'ORGANISATION_NAME' => 'PHILIP SUNLEY TRANSPORT LTD',
           'BUILDING_NAME' => 'LOWER LAUND FARM',
           'THOROUGHFARE_NAME' => 'LOWER LAUNDS',
           'DEPENDENT_LOCALITY' => 'SLAITHWAITE',
           'POST_TOWN' => 'HUDDERSFIELD',
           'POSTCODE' => 'HD7 5UZ' } }]
      end

      it 'returns the correct address' do
        address = service.call(result).first
        expect(address.address_line_one).to eq 'PHILIP SUNLEY TRANSPORT LTD'
        expect(address.address_line_two).to eq 'LOWER LAUND FARM, LOWER LAUNDS'
        expect(address.city).to eq 'HUDDERSFIELD'
        expect(address.county).to be nil
        expect(address.postcode).to eq 'HD7 5UZ'
      end
    end

    context 'building name, town, city, postcode' do
      let(:result) do
        [{ 'DPA' =>
         { 'ADDRESS' => 'THE LAITHE, SLAITHWAITE, HUDDERSFIELD, HD7 5UZ',
           'BUILDING_NAME' => 'THE LAITHE',
           'DEPENDENT_LOCALITY' => 'SLAITHWAITE',
           'POST_TOWN' => 'HUDDERSFIELD',
           'POSTCODE' => 'HD7 5UZ' } }]
      end

      it 'returns the correct address' do
        address = service.call(result).first
        expect(address.address_line_one).to eq 'THE LAITHE'
        expect(address.address_line_two).to eq 'SLAITHWAITE'
        expect(address.city).to eq 'HUDDERSFIELD'
        expect(address.county).to be nil
        expect(address.postcode).to eq 'HD7 5UZ'
      end
    end

    context 'organisation, building number, street, town, city, postcode' do
      let(:result) do
        [{ 'DPA' =>
         { 'ADDRESS' => 'GOAT HILL FARM, 2, GOAT HILL, SLAITHWAITE, HUDDERSFIELD, HD7 5UZ',
           'ORGANISATION_NAME' => 'GOAT HILL FARM',
           'BUILDING_NUMBER' => '2',
           'THOROUGHFARE_NAME' => 'GOAT HILL',
           'DEPENDENT_LOCALITY' => 'SLAITHWAITE',
           'POST_TOWN' => 'HUDDERSFIELD',
           'POSTCODE' => 'HD7 5UZ' } }]
      end

      it 'returns the correct address' do
        address = service.call(result).first
        expect(address.address_line_one).to eq 'GOAT HILL FARM'
        expect(address.address_line_two).to eq '2 GOAT HILL'
        expect(address.city).to eq 'HUDDERSFIELD'
        expect(address.county).to be nil
        expect(address.postcode).to eq 'HD7 5UZ'
      end
    end

    context 'organisation, building number, building name, street, town, city, postcode' do
      let(:result) do
        [{ 'DPA' =>
         { 'ADDRESS' => 'HARINGEY COUNCIL, RIVER PARK HOUSE, 225, HIGH ROAD, LONDON, N22 8HQ',
           'ORGANISATION_NAME' => 'HARINGEY COUNCIL',
           'BUILDING_NAME' => 'RIVER PARK HOUSE',
           'BUILDING_NUMBER' => '225',
           'THOROUGHFARE_NAME' => 'HIGH ROAD',
           'POST_TOWN' => 'LONDON',
           'POSTCODE' => 'N22 8HQ' } }]
      end

      it 'returns the correct address' do
        address = service.call(result).first
        expect(address.address_line_one).to eq 'HARINGEY COUNCIL'
        expect(address.address_line_two).to eq 'RIVER PARK HOUSE, 225 HIGH ROAD'
        expect(address.city).to eq 'LONDON'
        expect(address.county).to be nil
        expect(address.postcode).to eq 'N22 8HQ'
      end
    end

    context 'organisation, building sub-name, building number, street, town, city, postcode' do
      let(:result) do
        [{ 'DPA' =>
         { 'ADDRESS' => 'CLYDE OFFICES, 2/3, 48, WEST GEORGE STREET, GLASGOW, G2 1BP',
           'ORGANISATION_NAME' => 'CLYDE OFFICES',
           'SUB_BUILDING_NAME' => '2/3',
           'BUILDING_NUMBER' => '48',
           'THOROUGHFARE_NAME' => 'WEST GEORGE STREET',
           'POST_TOWN' => 'GLASGOW',
           'POSTCODE' => 'G2 1BP' } }]
      end

      it 'returns the correct address' do
        address = service.call(result).first
        expect(address.address_line_one).to eq 'CLYDE OFFICES'
        expect(address.address_line_two).to eq '2/3, 48 WEST GEORGE STREET'
        expect(address.city).to eq 'GLASGOW'
        expect(address.county).to be nil
        expect(address.postcode).to eq 'G2 1BP'
      end
    end

    context 'building name, building number, street, town, city, postcode' do
      let(:result) do
        [{ 'DPA' =>
         { 'ADDRESS' => 'FAKE HOUSE, 161, FAKE STREET, LONDON, W1 1ZZ',
           'BUILDING_NAME' => 'FAKE HOUSE',
           'BUILDING_NUMBER' => '161',
           'THOROUGHFARE_NAME' => 'FAKE STREET',
           'POST_TOWN' => 'LONDON',
           'POSTCODE' => 'W1 1ZZ' } }]
      end

      it 'returns the correct address' do
        address = service.call(result).first
        expect(address.address_line_one).to eq 'FAKE HOUSE'
        expect(address.address_line_two).to eq '161 FAKE STREET'
        expect(address.city).to eq 'LONDON'
        expect(address.county).to be nil
        expect(address.postcode).to eq 'W1 1ZZ'
      end
    end
  end
end
