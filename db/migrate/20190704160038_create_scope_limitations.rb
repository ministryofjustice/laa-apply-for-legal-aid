class CreateScopeLimitations < ActiveRecord::Migration[5.2]
  def change
    create_table :scope_limitations, id: :uuid do |t|
      t.string :code, index: true
      t.string :meaning
      t.string :description
      t.boolean :substantive, default: false
      t.boolean :delegated_functions, default: false
      t.timestamps
    end
  end
end
