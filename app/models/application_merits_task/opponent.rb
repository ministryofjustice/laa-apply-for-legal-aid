module ApplicationMeritsTask
  class Opponent < ApplicationRecord
    include NameSplitHelper
    include CCMSOpponentIdGenerator

    belongs_to :legal_aid_application
  end
end
