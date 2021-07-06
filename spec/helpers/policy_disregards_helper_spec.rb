require 'rails_helper'

RSpec.describe PolicyDisregardsHelper, type: :helper do
  include ApplicationHelper

  describe '#policy_disregards_hash' do
    let(:result) { policy_disregards_list(policy_disregards) }
    context 'no disregards selected' do
      let(:policy_disregards) { create :policy_disregards, none_selected: true }

      it 'does not return nil' do
        expect(policy_disregards_list(policy_disregards)).to_not be_nil
      end

      it 'returns the correct hash' do
        expect(policy_disregards_list(policy_disregards)).to eq(expected_result_none_selected)
      end
    end

    context 'disregards selected' do
      let(:policy_disregards) { create :policy_disregards, none_selected: false, england_infected_blood_support: true }

      it 'returns the correct hash' do
        expect(policy_disregards_list(policy_disregards)).to eq(expected_result)
      end
    end

    def expected_result_none_selected
      {
        items: [
          OpenStruct.new(label: 'England Infected Blood Support Scheme', amount_text: 'No'),
          OpenStruct.new(label: 'Vaccine Damage Payments Scheme', amount_text: 'No'),
          OpenStruct.new(label: 'Variant Creutzfeldt-Jakob disease (vCJD) Trust', amount_text: 'No'),
          OpenStruct.new(label: 'Criminal Injuries Compensation Scheme', amount_text: 'No'),
          OpenStruct.new(label: 'National Emergencies Trust (NET)', amount_text: 'No'),
          OpenStruct.new(label: 'We Love Manchester Emergency Fund', amount_text: 'No'),
          OpenStruct.new(label: 'The London Emergencies Trust', amount_text: 'No')
        ]
      }
    end

    def expected_result
      {
        items: [OpenStruct.new(label: 'England Infected Blood Support Scheme', amount_text: true)] + expected_result_none_selected[:items][1..]
      }
    end
  end
end
