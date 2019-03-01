class StatementOfCase < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :provider_uploader, class_name: 'Provider', optional: true
  has_many_attached :original_files
end
