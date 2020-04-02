class AddColumnToTransactionTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :transaction_types, :other_income, :boolean, default: 'false'
    TransactionType.where(name:
                              %w[friends_or_family
                                 maintenance_in
                                 property_or_lodger
                                 student_loan
                                 pension]).update_all(other_income: 'true')
  end
end
