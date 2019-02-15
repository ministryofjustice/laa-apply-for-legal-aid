require 'rails_helper'

RSpec.describe Addresses::AddressLookupForm, type: :form do
  let(:postcode) { 'SW1H9AJ' }
  let(:address) { build :address }
  let(:params) { { postcode: postcode, model: address } }
  subject(:form) { described_class.new(params) }

  describe 'validations' do
    it 'has no errors with normal postcode' do
      expect(form).to be_valid
    end

    context 'when postcode is invalid' do
      let(:postcode) { 'invalid' }

      it 'has an error on postcode' do
        expect(form).to be_invalid
        expect(form.errors[:postcode]).to match_array(['Enter a postcode in the right format'])
      end
    end

    context 'when the postcode is not entered' do
      let(:postcode) { '' }

      it 'has an error on postcode' do
        expect(form).to be_invalid
        expect(form.errors[:postcode]).to match_array(['Enter a postcode'])
      end
    end
  end

  describe 'save_as_draft' do
    before { form.save_as_draft }

    it 'has no errors with normal postcode' do
      expect(form).to be_valid
    end

    context 'when postcode is invalid' do
      let(:postcode) { 'invalid' }
      it 'has an error on postcode' do
        expect(form).to be_invalid
        expect(form.errors[:postcode]).to match_array(['Enter a postcode in the right format'])
      end
    end

    context 'when the postcode is not entered' do
      let(:postcode) { '' }

      it 'has an error on postcode' do
        expect(form).to be_valid
      end
    end
  end
end
