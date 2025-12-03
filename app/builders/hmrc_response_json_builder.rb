class HMRCResponseJsonBuilder < BaseJsonBuilder
  # TODO: AP-6376 DO WE NEED TO SEND THIS AT ALL, IF SO WAIT UNTIL DATATSTORE USES AUTHENTICATION
  def as_json
    {
      id:,
      legal_aid_application_id:,
      submission_id:,
      use_case:,
      # response:, EXCLUDED FOR NOW AS CONTAINS SESNITVE DATA, AS JSON, THAT WE NEED TO QUERY OUR PERMISSIONS TO SHARE WITH DATASTORE, DECIDE AND OTHERS. ALSO WE NEED AUTHENTICATED COMMUNICATIONS TO SHARE IT SAFELY.
      created_at:,
      updated_at:,
      url:,
      owner_type:,
      owner_id:,
    }
  end
end
