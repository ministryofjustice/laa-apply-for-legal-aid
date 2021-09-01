require 'rails_helper'

RSpec.describe NewBaseForm do
  describe '#exclude_from_model' do
    context 'when the derived form does not define #exclude_from_model' do
      it 'returns an empty array' do
        form = Addresses::AddressLookupForm.new
        expect(form.exclude_from_model).to eq []
      end
    end
  end

  describe '#squish_whitespaces' do
    let(:form) { Addresses::AddressForm.new(address_line_one: ' address line 1 ', address_line_two: '  address line 2 ', city: '  Manchester  ') }

    before { form.squish_whitespaces(:address_line_one, :city) }

    it 'squishes each of the named attributes' do
      expect(form.address_line_one).to eq 'address line 1'
      expect(form.city).to eq 'Manchester'
    end

    it 'does not squish attributes which are not specified' do
      expect(form.address_line_two).to eq '  address line 2 '
    end
  end
end
