module ProceedingMeritsTask
  class ApplicationProceedingTypeLinkedChild < ApplicationRecord
    self.table_name = :application_proceeding_types_linked_children
    belongs_to :application_proceeding_type
    belongs_to :involved_child, class_name: 'ApplicationMeritsTask::InvolvedChild'

    validate :correct_involved_child

    def correct_involved_child
      errors.add(:involved_child, 'belongs to another application') if application_proceeding_type.legal_aid_application_id != involved_child.legal_aid_application_id
    end
  end
end
