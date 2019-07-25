class CreateOfficesProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :offices_providers, id: false do |t|
      t.belongs_to :office, foreign_key: true, null: false, type: :uuid
      t.belongs_to :provider, foreign_key: true, null: false, type: :uuid
    end
  end
end
