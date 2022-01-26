class DocumentCategory < ApplicationRecord
  validates_with DocumentCategoryValidator

  def self.populate
    DocumentCategoryPopulator.call
  end

  def self.displayable_document_category_names
    where(display_on_evidence_upload: true).pluck(:name)
  end

  def self.submittable_category_names
    where(submit_to_ccms: true).pluck(:name)+['uncategorised']
  end
end
