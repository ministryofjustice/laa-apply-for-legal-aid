class PartnerJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      first_name:,
      last_name:,
      date_of_birth:,
      has_national_insurance_number:,
      national_insurance_number:,
      legal_aid_application_id:,
      created_at:,
      updated_at:,
      shared_benefit_with_applicant:,
      employed:,
      self_employed:,
      armed_forces:,
      full_employment_details:,
      receives_state_benefits:,
      student_finance:,
      student_finance_amount:,
      extra_employment_information:,
      extra_employment_information_details:,
      no_cash_income:,
      no_cash_outgoings:,
    }
  end
end
