class CreateContracts < ActiveRecord::Migration[8.0]
  def change
    create_table :contracts, id: :uuid do |t|
      t.belongs_to :office, foreign_key: true, null: false, type: :uuid
      t.string :category_of_law
      t.string :sub_category_of_law
      t.string :authorisation_type
      t.string :new_matters
      t.string :contractual_devolved_powers
      t.string :remainder_authorisation
    end
  end
end
