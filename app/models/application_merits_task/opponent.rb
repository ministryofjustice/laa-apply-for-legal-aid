module ApplicationMeritsTask
  class Opponent < ApplicationRecord
    include NameSplitHelper
    include CCMSOpponentIdGenerator

    belongs_to :legal_aid_application

    def ccms_relationship_to_case
      'OPP'
    end

    def ccms_child?
      false
    end

    def ccms_opponent_relationship_to_case
      'Opponent'
    end
  end
end
