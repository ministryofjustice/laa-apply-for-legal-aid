# frozen_string_literal: true

class AddProceedingIdToAttemptsToSettles < ActiveRecord::Migration[6.1]
  class MigrationAttemptsToSettle < ApplicationRecord
    self.table_name = :attempts_to_settles
  end

  def up
    MigrationAttemptsToSettle.all.each do |ats|
      apt_id = ats.application_proceeding_type_id
      apt = ApplicationProceedingType.find(apt_id)
      proceeding = Proceeding.where(legal_aid_application_id: apt.legal_aid_application_id, proceeding_case_id: apt.proceeding_case_id).first
      ats.update!(proceeding_id: proceeding.id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
