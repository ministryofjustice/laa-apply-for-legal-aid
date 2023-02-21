module ApplicationMeritsTask
  class Opponent < ApplicationRecord
    include CCMSOpponentIdGenerator

    belongs_to :legal_aid_application

    self.ignored_columns += %w[
      understands_terms_of_court_order
      understands_terms_of_court_order_details
      warning_letter_sent
      warning_letter_sent_details
      police_notified
      police_notified_details
      bail_conditions_set
      bail_conditions_set_details
    ]

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
