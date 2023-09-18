module ApplicationMeritsTask
  class Opponent < ApplicationRecord
    include CCMSOpponentIdGenerator

    belongs_to :opposable, polymorphic: true, dependent: :destroy
    belongs_to :legal_aid_application

    scope :individuals, -> { where(opposable_type: "ApplicationMeritsTask::Individual") }
    scope :organisations, -> { where(opposable_type: "ApplicationMeritsTask::Organisation") }

    delegate :first_name,
             :last_name,
             :full_name,
             :ccms_relationship_to_case,
             :ccms_child?,
             :ccms_opponent_relationship_to_case,
             :name,
             :ccms_type_code,
             :ccms_type_text,
             to: :opposable

    def individual?
      opposable.is_a?(Individual)
    end

    def organisation?
      opposable.is_a?(Organisation)
    end
  end
end
