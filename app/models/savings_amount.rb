class SavingsAmount < ApplicationRecord
  include Capital
  # include ValueTestable

  # def self.non_value_attrs
  #   %w[id legal_aid_application_id created_at updated_at]
  # end

  belongs_to :legal_aid_application
end
