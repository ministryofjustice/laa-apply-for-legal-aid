class ApplicationScopeLimitation < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :scope_limitation

  # This model is deprecated and will be removed in next ticket
end
