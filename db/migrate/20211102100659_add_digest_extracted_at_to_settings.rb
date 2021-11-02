class AddDigestExtractedAtToSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :settings, :digest_extracted_at, :datetime, default: Time.zone.at(1)
  end
end
