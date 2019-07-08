class Dependant < ApplicationRecord
  default_scope { order(number: :asc) }

  belongs_to :legal_aid_application
  delegate :submission_date, to: :legal_aid_application, prefix: true

  enum relationship: {
    child_relative: 'child_relative'.freeze,
    adult_relative: 'adult_relative'.freeze
  }

  def ordinal_number
    I18n.t("generic.ordinal_number.#{number}", default: number.ordinalize)
  end

  def age
    ((legal_aid_application_submission_date - date_of_birth) / 365.0)
  end

  def over_fifteen?
    age.floor > 15
  end

  def eighteen_or_less?
    age < 19
  end
end
