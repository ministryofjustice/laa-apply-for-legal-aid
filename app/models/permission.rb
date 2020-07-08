class Permission < ApplicationRecord
  def <=>(other)
    role <=> other.role
  end
end
