class CreateLegalAidApplicationRestrictions < ActiveRecord::Migration[5.2]
  def change
    create_table :legal_aid_application_restrictions, id: :uuid do |t|
      t.references(
        :legal_aid_application,
        foreign_key: true,
        type: :uuid,
        index: { name: 'laa_id_laa_restriction_id' }
      )
      t.references :restriction, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
