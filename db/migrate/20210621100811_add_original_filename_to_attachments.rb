class AddOriginalFilenameToAttachments < ActiveRecord::Migration[6.1]
  def change
    add_column :attachments, :original_filename, :text
  end
end
