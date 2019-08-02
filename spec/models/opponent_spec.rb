require 'rails_helper'

RSpec.describe Opponent, type: :model do
  let(:opponent) { create :opponent }

  describe 'method_missing' do
    context 'relationship to case' do
      context 'non-existent-attribute' do
        it 'raises NoMethodError' do
          expect {
            opponent.relationship_case_xxx?
          }.to raise_error NoMethodError, /undefined method `relationship_case_xxx\?' for /
        end
      end
      context 'existing attribute' do
        it 'compares the value on the relationship_to_case attribute' do
          expect(opponent.relationship_case_intervenor?).to be false
          expect(opponent.relationship_case_opponent?).to be true
        end
      end
    end

    context 'relationship to client' do
      context 'non-existent-attribute' do
        it 'raises NoMethodError' do
          expect {
            opponent.relationship_client_xxx?
          }.to raise_error NoMethodError, /undefined method `relationship_client_xxx\?' for /
        end
      end

      context 'existing attribute' do
        it 'compares the relationship_to_client_attribute' do
          expect(opponent.relationship_client_landlord?).to be false
          expect(opponent.relationship_client_ex_husband_wife?).to be true
        end
      end
    end

    context 'unknown method' do
      it 'raises No Method Error' do
        expect {
          opponent.xxxx
        }.to raise_error NoMethodError, /undefined method `xxxx' for/
      end
    end
  end

  describe '#full_name' do
    it 'concatentates title firstname and surname' do
      expect(opponent.full_name).to eq 'Mr. Dummy Opponent'
    end
  end

  describe '#person?' do
    it 'returns true if oppoonent type person' do
      expect(opponent.person?).to be true
    end

    it 'returns false if opponent type organisation' do
      opponent.opponent_type = 'Organisation'
      expect(opponent.person?).to be false
    end
  end

  describe '#respond_to_missing?' do
    context 'relationship case methods' do
      context 'valid attribute' do
        it 'returns true' do
          expect(opponent.respond_to?(:relationship_case_intervenor?)).to be true
        end
      end

      context 'invalid attribute' do
        it 'returns false' do
          expect(opponent.respond_to?(:relationship_case_xxx?)).to be false
        end
      end
    end

    context 'relationship client methods' do
      context 'valid attribute' do
        it 'returns true' do
          expect(opponent.respond_to?(:relationship_client_customer?)).to be true
        end
      end

      context 'invalid attribute' do
        it 'returns false' do
          expect(opponent.respond_to?(:relationship_client_xxx?)).to be false
        end
      end
    end

    context 'other methods' do
      it 'returns false' do
        expect(opponent.respond_to?(:xxx?)).to be false
      end
    end
  end

  describe '#other_party_relationship_to_client' do
    it "returns the other party's relationship to the client" do
      expect(opponent.other_party_relationship_to_client).to eq 'Ex_spouse'
    end
  end

  describe '#other_party_relationship_to_case' do
    it "returns the other party's relationship to the case" do
      expect(opponent.other_party_relationship_to_case).to eq 'Opp'
    end
  end

  describe '#organisation?' do
    before do
      opponent.opponent_type = 'Organisation'
    end
    it 'returns true if oppoonent type organisation' do
      expect(opponent.organisation?).to be true
    end
  end
end
