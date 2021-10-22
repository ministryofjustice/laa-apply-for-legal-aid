# frozen_string_literal: true

class AddProceedingIdToChancesOfSuccesses < ActiveRecord::Migration[6.1]
  class MigrationChancesOfSuccesses < ApplicationRecord
    self.table_name = :chances_of_successes
  end

  def up
    MigrationChancesOfSuccesses.all.each do |cos|
      apt_id = cos.application_proceeding_type_id
      apt = ApplicationProceedingType.find(apt_id)
      proceeding = Proceeding.where(legal_aid_application_id: apt.legal_aid_application_id, proceeding_case_id: apt.proceeding_case_id).first
      cos.update!(proceeding_id: proceeding.id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
