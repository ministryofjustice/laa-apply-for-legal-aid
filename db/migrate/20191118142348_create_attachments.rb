class CreateAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :attachments, id: :uuid do |t|
      t.uuid :legal_aid_application_id
      t.string :attachment_type
      t.uuid :pdf_attachment_id
      t.timestamps
    end
  end
end
