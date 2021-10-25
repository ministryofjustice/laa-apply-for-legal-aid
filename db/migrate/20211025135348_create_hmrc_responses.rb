class CreateHMRCResponses < ActiveRecord::Migration[6.1]
  def change
    create_table :hmrc_responses, id: :uuid do |t|
      t.string :application_id
      t.string :use_case
      t.json :response

      t.timestamps
    end
  end
end
