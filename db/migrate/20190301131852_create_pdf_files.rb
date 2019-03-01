class CreatePdfFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :pdf_files, id: :uuid do |t|
      t.uuid :original_file_id, null: false
    end
    add_index :pdf_files, :original_file_id, unique: true
  end
end
