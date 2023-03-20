class Partner < ApplicationRecord
  belongs_to :legal_aid_application, dependent: :destroy
end
