module ApplicationMeritsTask
  class Organisation < ApplicationRecord
    has_one :opponent, as: :opposable, dependent: :destroy

    delegate :generate_ccms_opponent_id, :ccms_opponent_id, to: :opponent

    alias_attribute :ccms_type_code, :ccms_code
    alias_attribute :ccms_type_text, :description

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
      name
    end

    def type
      "Organisation"
    end
  end
end
