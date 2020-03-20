class DropPdfFiles < ActiveRecord::Migration[5.2]
  def change
    drop_table :pdf_files, id: :uuid do |t|
      t.uuid :original_file_id, null: false
    end
  end
end
