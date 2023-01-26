class DigestExporter
  class SpreadsheetEmpty < StandardError; end

  def self.call
    new.call
  end

  def initialize
    log_message "Initializing"
    secret_file = StringIO.new(google_secret.to_json)
    @session = GoogleDrive::Session.from_service_account_key(secret_file)
    @worksheet = @session.spreadsheet_by_key(spreadsheet_key).worksheets[0]
    @rows = []
    delete_existing_data
    write_header_row
  end

  def call
    save_digest_to_rows(digest_ids)
    update_and_save_worksheet
  end

private

  def log_message(message)
    message = "Digest::Exporter :: #{message}"
    message = Time.zone.now.strftime("%F %T.%L ") + message if Rails.env.development?
    Rails.logger.info message
  end

  def update_and_save_worksheet
    log_message "update_and_save_worksheet"
    log_message "updating cells, @rows.count: #{@rows.count}"
    @worksheet.update_cells(2, 1, @rows)
    log_message "saving worksheet"
    @worksheet.save
    raise SpreadsheetEmpty, "Spreadsheet unexpectedly empty" if @worksheet.rows.count == 1

    log_message "All records written and worksheet saved"
  rescue SpreadsheetEmpty => e
    log_message "Job thinks it succeeded but the spreadsheet is empty"
    AlertManager.capture_exception(e)
    raise
  end

  def digest_ids
    @digest_ids ||= initialize_digest_ids
  end

  def initialize_digest_ids
    log_message "Getting digest ids"
    ApplicationDigest.order(:created_at).pluck(:id)
  end

  def save_digest_to_rows(digest_ids)
    log_message "save_digest_to_rows"
    log_message "#{digest_ids.size} records to be added to @rows"
    digest_ids.each_with_index do |digest_id, _index|
      digest = ApplicationDigest.find(digest_id)
      @rows << digest.to_google_sheet_row
    end
    log_message "@row.count: #{@rows.size}"
  end

  def delete_existing_data
    log_message "delete_existing_data"
    # You can't delete all the rows in a worksheet, so we delete all but one, and we'll overwrite that
    # with the column headers
    @worksheet.delete_rows(1, @worksheet.max_rows - 1)
    @worksheet.save
    log_message "Existing data removed from spreadsheet"
    log_message "@row.count: #{@rows.size}"
  end

  def write_header_row
    # Overwrite the 1 remaining row with column headers
    @worksheet.update_cells(1, 1, [ApplicationDigest.column_headers + extraction_date])
    @worksheet.save

    # It turns out that you have to re-initialise the worksheet, otherwise the deleted rows haven't really gone.
    @worksheet = @session.spreadsheet_by_key(spreadsheet_key).worksheets[0]
  end

  def extraction_date
    [
      "Extracted at: #{Time.zone.now}",
    ]
  end

  def spreadsheet_key
    ENV.fetch("GOOGLE_SHEETS_SPREADSHEET_ID", nil)
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
