class ApplicationScopeLimitation < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :scope_limitation
end
