class DestroyStudentLoanTransactionType < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    TransactionType.find_by(name: 'student_loan')&.destroy!

    # reset sort_order attribute of all transaction types
    Populators::TransactionTypePopulator.call
  end

  def down
    # Irreversible data migration. You will need the transaction_type_id of any child records to reverse this!
    # attribute values from production at time of writing:
    #
    #  "id"=>"a9de405c-74f7-45de-956f-4a602e994450"
    #  "name"=>"student_loan",
    #  "operation"=>"credit",
    #  "created_at"=>Mon, 29 Jul 2019 13:10:16.836407000 BST +01:00,
    #  "updated_at"=>Wed, 09 Oct 2024 07:32:36.113001000 BST +01:00,
    #  "sort_order"=>60,
    #  "archived_at"=>Wed, 09 Oct 2024 07:32:36.112851000 BST +01:00,
    #  "other_income"=>true,
    #  "parent_id"=>nil
    #
    nil
  end
end
