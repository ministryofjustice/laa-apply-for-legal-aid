class EmploymentJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      owner_type:,
      owner_id:,
      name:,
      created_at:,
      updated_at:,
      employment_payments: employment_payments.map { |ep| EmploymentPaymentJsonBuilder.build(ep).as_json },
    }
  end
end
