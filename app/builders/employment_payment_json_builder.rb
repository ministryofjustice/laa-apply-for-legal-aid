class EmploymentPaymentJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      employment_id:,
      date:,
      # EXCLUDED FOR NOW AS CONTAINS SESNITVE DATA, AS JSON, THAT WE NEED TO QUERY OUR PERMISSIONS TO SHARE WITH DATASTORE, DECIDE AND OTHERS. ALSO WE NEED AUTHENTICATED COMMUNICATIONS TO SHARE IT SAFELY.
      # gross:,
      # benefits_in_kind:,
      # national_insurance:,
      # tax:,
      # net_employment_income:,
      created_at:,
      updated_at:,
    }
  end
end
