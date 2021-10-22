# frozen_string_literal: true

class AddProceedingIdToLinkedChildren < ActiveRecord::Migration[6.1]
  class MigrationLinkedChildren < ApplicationRecord
    self.table_name = :application_proceeding_types_linked_children
  end

  def up
    MigrationLinkedChildren.all.each do |lc|
      apt_id = lc.application_proceeding_type_id
      apt = ApplicationProceedingType.find(apt_id)
      proceeding = Proceeding.where(legal_aid_application_id: apt.legal_aid_application_id, proceeding_case_id: apt.proceeding_case_id).first
      lc.update!(proceeding_id: proceeding.id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
