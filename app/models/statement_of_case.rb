class StatementOfCase < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :provider_uploader, class_name: 'Provider', optional: true
  has_one_attached :original_file
  has_one_attached :pdf_file
end
