class DestroyRedundantIrregularIncomes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    LegalAidApplication.where(student_finance: false).find_in_batches do |legal_aid_applications|
      legal_aid_applications.each do |legal_aid_application|
        legal_aid_application.irregular_incomes.destroy_all
      end
    end
  end

  def down
    nil
  end
end
