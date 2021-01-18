require 'rails_helper'

RSpec.describe PolicyDisregardsHelper, type: :helper do
  include ApplicationHelper

  describe '#policy_disregards_hash' do
    let(:result) { policy_disregards_hash(policy_disregards) }
    context 'no disregards selected' do
      let(:policy_disregards) { create :policy_disregards, none_selected: true }

      it 'returns nil' do
        expect(policy_disregards_hash(policy_disregards)).to be_nil
      end
    end

    context 'disregards selected' do
      let(:policy_disregards) { create :policy_disregards, none_selected: false, england_infected_blood_support: true }

      it 'returns a hash of the selected disregards' do
        expect(policy_disregards_hash(policy_disregards)).to eq(expected_result)
      end

      def expected_result
        {
          items: [
            OpenStruct.new(label: 'England Infected Blood Support Scheme', amount_text: true)
          ]
        }
      end
    end
  end
end
