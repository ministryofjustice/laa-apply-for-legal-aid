module ApplicationMeritsTask
  class InvolvedChild < ApplicationRecord
    include NameSplitHelper
    include CCMSOpponentIdGenerator

    belongs_to :legal_aid_application

    def ccms_other_party_type
      "PERSON"
    end

    def ccms_relationship_to_case
      "CHILD"
    end

    def ccms_relationship_to_client
      "UNKNOWN"
    end

    def ccms_child?
      true
    end

    def ccms_opponent_relationship_to_case
      "Child"
    end
  end
end
