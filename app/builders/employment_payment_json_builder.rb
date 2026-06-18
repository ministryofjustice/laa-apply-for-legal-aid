class EmploymentPaymentJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      employment_id:,
      date:,
      gross:,
      benefits_in_kind:,
      national_insurance:,
      tax:,
      net_employment_income:,
      created_at:,
      updated_at:,
    }
  end
end
