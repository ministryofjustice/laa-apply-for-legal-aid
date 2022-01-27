class Attachment < ApplicationRecord
  belongs_to :legal_aid_application
  has_one_attached :document

  validates_with DocumentCategoryValidator

  DocumentCategoryValidator::VALID_DOCUMENT_TYPES.each do |named_scope|
    scope named_scope.to_sym, -> { where(attachment_type: named_scope) }
  end

  scope :uploadable_evidence_types, -> { where(attachment_type: DocumentCategory.submittable_category_names) }
  scope :displayable_evidence_types, -> { where(attachment_type: DocumentCategory.displayable_document_category_names + ['uncategorised']) }
end
