require 'rails_helper'

RSpec.describe Applicants::AddressLookupForm, type: :form do
  subject(:form) { described_class.new(params) }

  describe 'validations' do
    context 'when the form field is valid' do
      let(:params) { { postcode: 'SW1H9AJ' } }

      it { is_expected.to be_valid }
    end

    context 'when the postcode is not entered' do
      let(:params) { { postcode: '' } }

      it 'should have an error on postcode' do
        expect(form).not_to be_valid
        expect(form.errors[:postcode]).to match_array(['Enter a postcode'])
      end
    end
  end
end
