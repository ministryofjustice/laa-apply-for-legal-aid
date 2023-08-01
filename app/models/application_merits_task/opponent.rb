module ApplicationMeritsTask
  class Opponent < ApplicationRecord
    include CCMSOpponentIdGenerator

    belongs_to :opposable, polymorphic: true, dependent: :destroy
    belongs_to :legal_aid_application

    # TODO: remove this when we remove the first and last name attributes from opponent - review from 31/07/2023
    # NOTE: This is purely to continue to fill data on the opponent in case we need to rollback
    before_save do
      if opposable.is_a?(Individual)
        self.first_name = opposable.first_name
        self.last_name = opposable.last_name
      end
    end

    delegate :first_name,
             :last_name,
             :full_name,
             :ccms_relationship_to_case,
             :ccms_child?,
             :ccms_opponent_relationship_to_case,
             :name,
             :ccms_code,
             :description,
             :type,
             to: :opposable
  end
end
