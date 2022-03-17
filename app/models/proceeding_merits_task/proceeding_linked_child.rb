module ProceedingMeritsTask
  class ProceedingLinkedChild < ApplicationRecord
    self.table_name = :proceedings_linked_children
    belongs_to :proceeding
    belongs_to :involved_child, class_name: "ApplicationMeritsTask::InvolvedChild"

    validate :correct_involved_child

    def correct_involved_child
      errors.add(:involved_child, "belongs to another application") if proceeding.legal_aid_application_id != involved_child.legal_aid_application_id
    end
  end
end
