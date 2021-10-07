class Proceeding < ApplicationRecord
  belongs_to :legal_aid_application

  scope :in_order_of_addition, -> { order(:created_at) }

  scope :using_delegated_functions, -> { where.not(used_delegated_functions_on: nil).order(:used_delegated_functions_on) }

  scope :not_using_delegated_functions, -> { where(used_delegated_functions_on: nil) }

  def used_delegated_functions?
    used_delegated_functions_on.present?
  end
end
