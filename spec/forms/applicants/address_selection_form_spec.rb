require 'rails_helper'

RSpec.describe Applicants::AddressSelectionForm, type: :form do
  let(:postcode) { 'DA7 4NG' }
  let(:address) { '{"line_one":"5","line_two":"LONSDALE ROAD","city":"BEXLEYHEATH","postcode":"DA7 4NG"}' }
  let(:applicant_id) { SecureRandom.uuid }
  let(:form_params) do
    {
      address: address,
      postcode: postcode
    }
  end
  subject(:form) { described_class.new(form_params.merge(applicant_id: applicant_id)) }

  describe 'validations' do
    it 'is valid with all the required attributes' do
      expect(form).to be_valid
    end

    context 'when address is blank' do
      let(:address) { '' }

      it 'contains a presence error on the address' do
        expect(form).not_to be_valid
        expect(form.errors[:address]).to match_array(['Please select an address from the list'])
      end
    end
  end
end
