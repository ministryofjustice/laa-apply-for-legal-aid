class AdminReport < ApplicationRecord
  has_one_attached :submitted_applications
  has_one_attached :non_passported_applications
end
