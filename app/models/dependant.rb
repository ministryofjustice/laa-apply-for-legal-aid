class Dependant < ApplicationRecord
  default_scope { order(number: :asc) }

  belongs_to :legal_aid_application

  enum relationship: {
    child_relative: 'child_relative'.freeze,
    adult_relative: 'adult_relative'.freeze
  }

  def ordinal_number
    I18n.t("generic.ordinal_number.#{number}", default: number.ordinalize)
  end

  def age
    AgeCalculator.call(date_of_birth, legal_aid_application.calculation_date)
  end

  def over_fifteen?
    age > 15
  end

  def eighteen_or_less?
    age < 19
  end
end
