require 'rails_helper'

module ApplicationMeritsTask
  RSpec.describe Opponent do
    describe 'CCMSOpponentIdGenerator concern' do
      let(:expected_id) { Faker::Number.number(digits: 8) }

      context 'ccms_opponent_id is nil' do
        before { expect(CCMS::OpponentId).to receive(:next_serial_id).and_return(expected_id) }

        let(:opponent) { create :opponent, ccms_opponent_id: nil }

        it 'returns the next serial id' do
          expect(opponent.generate_ccms_opponent_id).to eq expected_id
        end

        it 'updates the ccms_opponent_id on the record' do
          opponent.generate_ccms_opponent_id
          expect(opponent.reload.ccms_opponent_id).to eq expected_id
        end
      end

      context 'ccms_opponent_id is already populated' do
        before { expect(CCMS::OpponentId).not_to receive(:next_serial_id) }

        let(:opponent) { create :opponent, ccms_opponent_id: 1234 }

        it 'returns the value' do
          expect(opponent.generate_ccms_opponent_id).to eq 1234
        end

        it 'does not update the record with a different value' do
          opponent.generate_ccms_opponent_id
          expect(opponent.reload.ccms_opponent_id).to eq 1234
        end
      end
    end
  end
end
