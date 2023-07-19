module ApplicationMeritsTask
  class Individual < ApplicationRecord
    has_one :opponent, as: :opposable, dependent: :destroy

    delegate :generate_ccms_opponent_id, to: :opponent

    def ccms_relationship_to_case
      "OPP"
    end

    def ccms_child?
      false
    end

    def ccms_opponent_relationship_to_case
      "Opponent"
    end

    def full_name
      "#{first_name} #{last_name}".strip
    end
  end
end
