class ApplicationScopeLimitation < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :scope_limitation

  def self.substantive_scope_limitation
    find_by(substantive: true)&.scope_limitation
  end

  def self.delegated_functions_scope_limitation
    find_by(substantive: false)&.scope_limitation
  end
end
