class MarkStudentLoanTransactionTypeAsArchived < ActiveRecord::Migration[6.0]
  def up
    rec = TransactionType.find_by(name: 'student_loan')
    rec.update!(archived_at: Time.current) if rec.archived_at.nil?
  end

  def down
    rec = TransactionType.find_by(name: 'student_loan')
    rec.update!(archived_at: nil)
  end
end
