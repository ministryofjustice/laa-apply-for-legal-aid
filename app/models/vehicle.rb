class Vehicle < ApplicationRecord
  belongs_to :legal_aid_application

  def complete?
    [
      estimated_value.present?,
      more_than_three_years_old.in?([true, false]),
      used_regularly.in?([true, false]),
    ].all?(true)
  end

  def cfe_civil_purchase_date
    more_than_three_years_old? ? 4.years.ago.to_date : 2.years.ago.to_date
  end
end
