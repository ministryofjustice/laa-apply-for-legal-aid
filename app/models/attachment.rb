class Attachment < ApplicationRecord
  belongs_to :legal_aid_application
  has_one_attached :document

  validates_with DocumentCategoryValidator

  DocumentCategoryValidator::VALID_DOCUMENT_TYPES.each do |named_scope|
    scope named_scope.to_sym, -> { where(attachment_type: named_scope) }
  end
end
