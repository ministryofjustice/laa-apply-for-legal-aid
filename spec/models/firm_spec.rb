require 'rails_helper'

RSpec.describe 'Firm' do
  let(:firm) { create :firm }

  describe '#permissions' do
    context 'when there are no permissions' do
      it 'returns and empty collection' do
        expect(firm.permissions).to be_empty
      end
    end

    context 'when there are permissions' do
      let!(:permission1) { create :permission }
      let!(:permission2) { create :permission }

      context 'with just permission 2' do
        before do
          firm.permissions << permission2
          firm.save!
        end

        it 'returns just the one permission' do
          expect(firm.reload.permissions).to eq [permission2]
        end
      end

      context 'with both permissions' do
        before do
          firm.permissions << permission2
          firm.permissions << permission1
          firm.save!
        end

        it 'returns just both permissions' do
          expect(firm.reload.permissions).to match_array [permission2, permission1]
        end
      end
    end
  end
end
