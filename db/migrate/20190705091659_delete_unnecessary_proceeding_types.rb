class DeleteUnnecessaryProceedingTypes < ActiveRecord::Migration[5.2]
  def safe_proceeding_id
    ProceedingType.find_by(ccms_code: 'DA001').id
  end

  def proceeding_ids_to_be_deleted
    ProceedingType.where.not(ccms_code: %w[DA001 DA002 DA003 DA004 DA005 DA006 DA007]).pluck(:id)
  end

  def up
    return if ProceedingType.count.zero?

    ApplicationProceedingType.where(proceeding_type_id: proceeding_ids_to_be_deleted).update_all(proceeding_type_id: safe_proceeding_id)
    ProceedingType.delete(proceeding_ids_to_be_deleted)
  end

  def down; end
end
