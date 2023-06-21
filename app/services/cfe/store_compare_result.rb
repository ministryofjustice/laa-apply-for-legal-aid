module CFE
  class StoreCompareResult
    include SharedGoogleSheet
    # NOTE: This is intended as a temporary class while we switch from CFE-Legacy to CFE-Civil
    # Once that change over is complete, the aim is that this can be removed, along with

    def self.call(value_array)
      new.call(value_array)
    end

    def initialize
      log_message "Initializing"
      secret_file = StringIO.new(google_secret.to_json)
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: secret_file, scope: SCOPE)
      authorizer.fetch_access_token!

      @sheet_service = Google::Apis::SheetsV4::SheetsService.new
      @sheet_service.authorization = authorizer
      worksheet_reload
      @rows = []
    end

    def call(row)
      @rows = [row]
      range = "Sheet1!A1:A"
      value_range = Google::Apis::SheetsV4::ValueRange.new(major_dimension: "ROWS",
                                                           range:,
                                                           values: @rows)
      output = @sheet_service.append_spreadsheet_value(spreadsheet_key,
                                                       range,
                                                       value_range,
                                                       value_input_option: "USER_ENTERED")
      log_message = output.updates.updated_range
      log_message "Updated #{log_message}"
    end

  private

    def worksheet_reload
      @spreadsheet = @sheet_service.get_spreadsheet(spreadsheet_key)
    end
  end
end
