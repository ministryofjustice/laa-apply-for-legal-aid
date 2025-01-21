class DropGatewayEvidencesTable < ActiveRecord::Migration[7.2]
  def change
    drop_table :gateway_evidences, force: :cascade
  end
end
