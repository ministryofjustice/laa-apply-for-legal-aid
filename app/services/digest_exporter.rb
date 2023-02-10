class DigestExporter
  class SpreadsheetError < StandardError; end

  SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

  def self.call
    new.call
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

  def call
    reset_worksheet
    populate_rows
    update_and_save_worksheet
  end

private

  def log_message(message)
    message = "Digest::Exporter :: #{message}"
    message = Time.zone.now.strftime("%F %T.%L ") + message if Rails.env.development?
    Rails.logger.info message
  end

  def worksheet_reload
    @spreadsheet = @sheet_service.get_spreadsheet(spreadsheet_key)
    @worksheet = @spreadsheet.sheets[0]
  end

  def reset_worksheet
    log_message "reset_worksheet"
    clear("ROWS") unless @worksheet.properties.grid_properties.row_count == 1
    clear("COLUMNS") unless @worksheet.properties.grid_properties.column_count == 1
    worksheet_reload
    raise SpreadsheetError, "Spreadsheet not cleared" if @worksheet.properties.grid_properties.row_count > 1 || @worksheet.properties.grid_properties.column_count > 1

    log_message "Existing data removed from spreadsheet"
    log_message "@worksheet.rows.count: #{@worksheet.properties.grid_properties.row_count}"
  end

  def populate_rows
    log_message "save_digest_to_rows"
    log_message "Adding #{column_headers.count + 1} column headers, ApplicationDigest.column_headers + extraction date, to @rows"
    @rows << [column_headers + extraction_date].flatten
    log_message "#{digest_ids.size} records to be added to @rows"
    digest_ids.each_with_index do |digest_id, _index|
      digest = ApplicationDigest.find(digest_id)
      @rows << digest.to_google_sheet_row
    end
    log_message "@row.count: #{@rows.size}"
    log_message "@worksheet.max_rows: #{@worksheet.properties.grid_properties.row_count}"
  end

  def update_and_save_worksheet
    log_message "update_and_save_worksheet"
    range = "Sheet1!R1C1:R#{@rows.count}C#{@rows.first.count}"
    value_range = Google::Apis::SheetsV4::ValueRange.new(major_dimension: "ROWS",
                                                         range:,
                                                         values: @rows)
    @sheet_service.update_spreadsheet_value(spreadsheet_key,
                                            range,
                                            value_range,
                                            value_input_option: "USER_ENTERED")
  end

  def digest_ids
    @digest_ids ||= ApplicationDigest.order(:created_at).pluck(:id)
  end

  def column_headers
    ApplicationDigest.column_headers
  end

  def spreadsheet_key
    ENV.fetch("GOOGLE_SHEETS_SPREADSHEET_ID", nil)
  end

  def extraction_date
    [
      "Extracted at: #{Time.zone.now}",
    ]
  end

  def clear(type)
    index = type.eql?("ROWS") ? :row_count : :column_count
    range = Google::Apis::SheetsV4::DimensionRange.new(sheet_id: @worksheet.properties.sheet_id,
                                                       dimension: type,
                                                       start_index: 1,
                                                       end_index: @worksheet.properties.grid_properties.send(index))
    update_request = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(
      requests: [delete_dimension: Google::Apis::SheetsV4::DeleteDimensionRequest.new(range:)],
    )

    @sheet_service.batch_update_spreadsheet(spreadsheet_key, update_request)
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
