require 'rails_helper'

RSpec.describe 'Firm' do
  let!(:firm) { create :firm, name: 'Testing, Test & Co' }

  describe '#permissions' do
    context 'when there are no permissions' do
      it 'returns an empty collection' do
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

        it 'returns both permissions' do
          expect(firm.reload.permissions).to match_array [permission2, permission1]
        end

        it 'returns all permissions' do
          expect(firm.permissions.all).to match_array [permission2, permission1]
        end
      end
    end
  end

  describe 'search' do
    let!(:firm2) { create :firm, name: 'Cage and Fish' }
    let!(:firm3) { create :firm, name: 'Harvey Birdman & Co.' }

    context 'search for a firm' do
      it 'returns a single record' do
        expect(Firm.search('Harvey')).to eq([firm3])
      end
    end

    context 'returns all records' do
      it 'returns all  record' do
        expect(Firm.search('')).to match_array([firm3, firm2, firm])
      end
    end
  end
end
