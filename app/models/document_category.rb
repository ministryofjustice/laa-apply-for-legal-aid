class DocumentCategory < ApplicationRecord
  def self.populate
    DocumentCategoryPopulator.call
  end

  scope :valid_document_categories, -> { where(display_on_evidence_upload: true).pluck(:name) }
end
