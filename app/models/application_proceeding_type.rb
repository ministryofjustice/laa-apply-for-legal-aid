class ApplicationProceedingType < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :proceeding_type
end
