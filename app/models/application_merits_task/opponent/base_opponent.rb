module ApplicationMeritsTask
  module Opponent
    class BaseOpponent < ApplicationRecord
      include CCMSOpponentIdGenerator

      belongs_to :legal_aid_application

      self.table_name = "opponents"

      def ccms_relationship_to_case
        "OPP"
      end

      def ccms_child?
        false
      end

      def ccms_opponent_relationship_to_case
        "Opponent"
      end
    end
  end
end
