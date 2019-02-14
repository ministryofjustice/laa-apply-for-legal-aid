class StatementOfCase < ApplicationRecord
  belongs_to :legal_aid_application
  has_one_attached :original_file
end
