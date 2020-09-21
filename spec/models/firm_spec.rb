require 'rails_helper'

RSpec.describe 'Firm' do
  let!(:firm) { create :firm, name: 'Testing, Test & Co' }

  describe '#permissions' do
    context 'when there are no permissions' do
      let!(:default_permission) { create :permission }
      let(:firm_with_no_permission) { create :firm }

      before do
        allow_any_instance_of(Firm).to receive(:passported_permission_id).and_return(default_permission.id)
      end

      it 'has a default permission' do
        expect(firm_with_no_permission.permissions).to eq [default_permission]
      end
    end

    context 'when there are permissions' do
      let(:default_permission) { Permission.find_by(role: 'application.passported.*') }
      let!(:permission1) { create :permission }
      let!(:permission2) { create :permission }

      context 'with just the default permission' do
        it 'returns the default permission' do
          expect(firm.reload.permissions).to eq [default_permission]
        end
      end

      context 'with additional permissions added' do
        before do
          firm.permissions << permission2
          firm.permissions << permission1
          firm.save!
        end

        it 'returns the correct permissions' do
          expect(firm.reload.permissions).to match_array [default_permission, permission2, permission1]
        end

        it 'returns all permissions' do
          expect(firm.permissions.all).to match_array [default_permission, permission2, permission1]
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
