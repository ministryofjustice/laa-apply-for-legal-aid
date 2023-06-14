module CFE
  class StoreCompareResult
    # NOTE: This is intended as a temporary class while we switch from CFE-Legacy to CFE-Civil
    # Once that change over is complete, the aim is that this can be removed, along with
    SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

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
      requests = [{ clear_basic_filter: { sheet_id: @spreadsheet.sheets[0].properties.sheet_id } }]
      update_request = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(requests:)
      @sheet_service.batch_update_spreadsheet(spreadsheet_key, update_request)
    end

    def spreadsheet_key
      @spreadsheet_key ||= ENV.fetch("CFE_COMPARISON_SHEET_ID", nil)
    end

    def log_message(message)
      message = "#{self.class} :: #{message}"
      message = Time.current.strftime("%F %T.%L ") + message if Rails.env.development?
      Rails.logger.info message
    end

    def google_secret
      {
        type: "service_account",
        project_id: "laa-apply-for-legal-aid",
        private_key_id: ENV.fetch("GOOGLE_SHEETS_PRIVATE_KEY_ID", nil),
        private_key: ENV.fetch("GOOGLE_SHEETS_PRIVATE_KEY_VALUE", nil),
        client_email: ENV.fetch("GOOGLE_SHEETS_CLIENT_EMAIL", nil),
        client_id: ENV.fetch("GOOGLE_SHEETS_CLIENT_ID", nil),
        auth_uri: "https://accounts.google.com/o/oauth2/auth",
        token_uri: "https://oauth2.googleapis.com/token",
        auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
        client_x509_cert_url: "https://www.googleapis.com/robot/v1/metadata/x509/laa-apply-service%40laa-apply-for-legal-aid.iam.gserviceaccount.com",
      }
    end
  end
end
