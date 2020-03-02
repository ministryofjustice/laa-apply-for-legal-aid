class Vehicle < ApplicationRecord
  belongs_to :legal_aid_application

  def purchased_on
    self[:purchased_on].nil? ? inferred_purchase_date : self[:purchased_on]
  end

  private

  def inferred_purchase_date
    more_than_three_years_old? ? 4.years.ago.to_date : 2.years.ago.to_date
  end
end
