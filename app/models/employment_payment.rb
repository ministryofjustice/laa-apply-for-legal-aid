class EmploymentPayment < ApplicationRecord
  belongs_to :employment

  before_save :calculate_net_employment_income

  private

  def calculate_net_employment_income
    self.net_employment_income = (gross + benefits_in_kind + tax + national_insurance).round(2)
  end
end
