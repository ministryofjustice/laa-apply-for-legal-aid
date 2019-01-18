class AddProviderToLegalAidApplication < ActiveRecord::Migration[5.2]
  def change
    add_reference :legal_aid_applications, :provider, type: :uuid, index: true, foreign_key: true
  end
end
