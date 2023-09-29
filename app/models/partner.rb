class Partner < ApplicationRecord
  belongs_to :legal_aid_application, dependent: :destroy
  has_many :hmrc_responses, class_name: "HMRC::Response", as: :owner
  has_many :employments, as: :owner
  has_many :regular_transactions, as: :owner

  delegate :transaction_period_start_on, to: :legal_aid_application

  def json_for_hmrc
    {
      first_name:,
      last_name:,
      dob: date_of_birth,
      nino: national_insurance_number,
    }
  end

  def full_name
    "#{first_name} #{last_name}".strip
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

  def state_benefits
    regular_transactions.where(transaction_type_id: TransactionType.find_by(name: "benefits")).order(:created_at)
  end

  def has_offline_savings?
    legal_aid_application.savings_amount.attributes.values_at("partner_offline_current_accounts", "partner_offline_savings_accounts").any?
  end
end
