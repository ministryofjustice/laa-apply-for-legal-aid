class CreateTempContractData < ActiveRecord::Migration[7.1]
  def change
    create_table :temp_contract_data, id: :uuid do |t|
      t.boolean :success
      t.string :office_code
      t.json :response

      t.timestamps
    end
  end
end
