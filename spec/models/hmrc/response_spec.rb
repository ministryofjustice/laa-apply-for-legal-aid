require 'rails_helper'

module HMRC
  RSpec.describe Response, type: :model do
    subject(:response) { build(:hmrc_response) }

    describe 'validations' do
      subject(:valid) { response.valid? }
      it 'is valid with all valid attributes' do
        expect(valid).to be true
      end

      context 'when the use case is not valid for apply' do
        let(:response) { build(:hmrc_response, use_case: 'three') }

        it { is_expected.to be false }
      end
    end
  end
end
