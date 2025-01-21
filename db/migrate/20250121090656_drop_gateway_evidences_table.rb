class DropGatewayEvidencesTable < ActiveRecord::Migration[7.2]
  def change
    drop_table :gateway_evidences, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.belongs_to :legal_aid_application, null: false, type: :uuid
      t.uuid :provider_uploader_id, type: :uuid, index: true
      t.timestamps
    end
  end
end
