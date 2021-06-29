module ApplicationMeritsTask
  class InvolvedChild < ApplicationRecord
    include NameSplitHelper
    include CCMSOpponentIdGenerator

    belongs_to :legal_aid_application
    has_many :application_proceeding_type_linked_children, class_name: 'ProceedingMeritsTask::ApplicationProceedingTypeLinkedChild', dependent: :destroy

    def ccms_relationship_to_case
      'CHILD'
    end

    def ccms_child?
      true
    end

    def ccms_opponent_relationship_to_case
      'Child'
    end
  end
end
