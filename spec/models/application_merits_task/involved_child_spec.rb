require 'rails_helper'

module ApplicationMeritsTask
  RSpec.describe InvolvedChild do
    describe 'standard values' do
      subject(:involved_child) { build :involved_child }

      it { expect(involved_child.ccms_relationship_to_case).to eq 'CHILD' }
      it { expect(involved_child.ccms_child?).to eq true }
      it { expect(involved_child.ccms_opponent_relationship_to_case).to eq 'Child' }
    end

    describe '#split_full_name' do
      let(:involved_child) { build :involved_child, full_name: full_name }

      subject { involved_child.split_full_name }

      context 'first name and last name' do
        let(:full_name) { 'John Smith' }
        it 'separates out first and last name' do
          expect(subject).to eq %w[John Smith]
        end
      end

      context 'with  multiple embedded spaces' do
        let(:full_name) { 'Michael      Winner' }
        it 'separates out first and last name' do
          expect(subject).to eq %w[Michael Winner]
        end
      end

      context 'first name, middle name, last name' do
        let(:full_name) { 'Philip   Stephen    Richards' }
        it 'separates out first and last name' do
          expect(subject).to eq ['Philip Stephen', 'Richards']
        end
      end

      context 'just last name' do
        let(:full_name) { 'Prince' }
        it 'returns unspecified as first name' do
          expect(subject).to eq %w[unspecified Prince]
        end
      end

      context 'double-barrelled names' do
        let(:full_name) { 'Jacob Rees-Mogg' }
        it 'is not phased by the hyphen' do
          expect(subject).to eq %w[Jacob Rees-Mogg]
        end
      end

      context 'irish names' do
        let(:full_name) { "Daira O'Brien" }
        it 'is not phased by the apostrophe' do
          expect(subject).to eq ['Daira', "O'Brien"]
        end
      end
    end

    describe 'CCMSOpponentIdGenerator concern' do
      let(:expected_id) { Faker::Number.number(digits: 8) }

      context 'ccms_opponent_id is nil' do
        before { expect(CCMS::OpponentId).to receive(:next_serial_id).and_return(expected_id) }

        let(:involved_child) { create :involved_child, full_name: 'John Doe', ccms_opponent_id: nil }

        it 'returns the next serial id' do
          expect(involved_child.generate_ccms_opponent_id).to eq expected_id
        end

        it 'updates the ccms_opponent_id on the record' do
          involved_child.generate_ccms_opponent_id
          expect(involved_child.reload.ccms_opponent_id).to eq expected_id
        end
      end

      context 'ccms_opponent_id is already populated' do
        before { expect(CCMS::OpponentId).not_to receive(:next_serial_id) }

        let(:involved_child) { create :involved_child, full_name: 'John Doe', ccms_opponent_id: 4553 }

        it 'returns the value' do
          expect(involved_child.generate_ccms_opponent_id).to eq 4553
        end

        it 'does not update the record with a different value' do
          involved_child.generate_ccms_opponent_id
          expect(involved_child.reload.ccms_opponent_id).to eq 4553
        end
      end
    end
  end
end
