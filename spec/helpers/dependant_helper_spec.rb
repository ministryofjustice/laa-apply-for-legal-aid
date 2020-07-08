require 'rails_helper'

RSpec.describe DependantHelper, type: :helper do
  include ApplicationHelper
  let(:dependant) { create :dependant }

  describe '#dependant_hash' do
    subject(:dependant_helper) { dependant_hash(dependant) }

    it { is_expected.to be_a(Hash) }
  end
end
