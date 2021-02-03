require 'rails_helper'

RSpec.describe PolicyDisregards, type: :model do
  let(:application) { create :legal_aid_application, :with_single_policy_disregard }

  let(:expected_json) do
    {
      category: 'policy_disregards',
      details: %w[vaccine_damage_payments]
    }
  end

  describe 'as_json' do
    subject(:as_json) { application.policy_disregards.as_json }

    it { is_expected.to eq expected_json }
  end
end
