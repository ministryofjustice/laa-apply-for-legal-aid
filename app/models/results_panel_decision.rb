class ResultsPanelDecision < ApplicationRecord
  def self.populate
    ResultsPanelDecisionsPopulator.call
  end
end
