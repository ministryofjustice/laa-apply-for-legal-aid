class Partner < ApplicationRecord
  belongs_to :legal_aid_application, dependent: :destroy
  has_many :hmrc_responses, class_name: "HMRC::Response", as: :owner
  has_many :employments, as: :owner

  delegate :transaction_period_start_on, to: :legal_aid_application

  def json_for_hmrc
    {
      first_name:,
      last_name:,
      dob: date_of_birth,
      nino: national_insurance_number,
    }
  end

  def hmrc_employment_income?
    employments.any?
  end

  def has_multiple_employments?
    employments.length > 1
  end

  def eligible_employment_payments
    employment_payments.select { |p| p.date >= transaction_period_start_on }
  end

  def employment_payments
    employments.map(&:employment_payments).flatten
  end
end
