class AssignedScopeLimitation < ApplicationRecord
  belongs_to :application_proceeding_type
  belongs_to :scope_limitation

  # should the relationship below exist here?
  #   has_many :scope_limitations

  def self.substantive_scope_limitation
    find_by(substantive: true)&.scope_limitation
  end

  def self.delegated_functions_scope_limitation
    find_by(substantive: false)&.scope_limitation
  end
end
