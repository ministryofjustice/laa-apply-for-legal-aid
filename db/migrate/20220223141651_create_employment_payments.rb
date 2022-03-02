class CreateEmploymentPayments < ActiveRecord::Migration[6.1]
  def change
    create_table :employment_payments, id: :uuid do |t|
      t.references :employment, foreign_key: true, type: :uuid
      t.date :date, null: false
      t.decimal :gross, default: 0.0, null: false
      t.decimal :benefits_in_kind, default: 0.0, null: false
      t.decimal :national_insurance, default: 0.0, null: false
      t.decimal :tax, default: 0.0, null: false
      t.decimal :net_employment_income, default: 0.0, null: false

      t.timestamps
    end
  end
end
