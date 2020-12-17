require 'rails_helper'

RSpec.describe DependantHelper, type: :helper do
  include ApplicationHelper
  let(:dependant) { create :dependant }

  describe '#dependant_hash' do
    subject(:dependant_helper) do
      puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
      dependant_hash(dependant)
    end

    it { is_expected.to be_a(Hash) }
  end
end
