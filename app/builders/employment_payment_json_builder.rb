class EmploymentPaymentJsonBuilder < BaseJsonBuilder
  # TODO: AP-6376 DO WE NEED TO SEND THIS AT ALL, IF SO WAIT UNTIL DATATSTORE USES AUTHENTICATION
  def as_json
    {
      id:,
      employment_id:,
      date:,
      # EXCLUDED FOR NOW AS CONTAINS SENSITVE DATA. DO WE NEED TO QUERY OUR PERMISSIONS TO SHARE THIS WITH DATASTORE, DECIDE AND OTHERS. ALSO WE NEED AUTHENTICATED COMMUNICATIONS TO SHARE IT SAFELY.
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
