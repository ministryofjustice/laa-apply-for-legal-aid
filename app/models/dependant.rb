class Dependant < ApplicationRecord
  default_scope { order(number: :asc) }

  belongs_to :legal_aid_application
  delegate :submission_date, to: :legal_aid_application, prefix: true

  def ordinal_number
    I18n.t("generic.ordinal_number.#{number}", default: number.ordinalize)
  end

  def age
    ((legal_aid_application_submission_date - date_of_birth) / 365.0)
  end

  def over_fifteen?
    age.floor > 15
  end
end
