# frozen_string_literal: true

class AddProceedingIdToLinkedChildren < ActiveRecord::Migration[6.1]
  class MigrationLinkedChildren < ApplicationRecord
    self.table_name = :proceedings_linked_children

    belongs_to :proceeding
    belongs_to :involved_child, class_name: 'ApplicationMeritsTask::InvolvedChild'

    validate :correct_involved_child

    def correct_involved_child
      errors.add(:involved_child, 'belongs to another application') if proceeding.legal_aid_application_id != involved_child.legal_aid_application_id
    end
  end

  def up
    ProceedingMeritsTask::ApplicationProceedingTypeLinkedChild.all.each do |aptlc|
      apt = aptlc.application_proceeding_type
      proceeding = apt.proceeding
      involved_child = aptlc.involved_child
      MigrationLinkedChildren.create!(proceeding_id: proceeding.id, involved_child_id: involved_child.id)
    end
  end

  def down
    MigrationLinkedChildren.delete_all
  end
end
