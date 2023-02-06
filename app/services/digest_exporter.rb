class DigestExporter
  class SpreadsheetEmpty < StandardError; end

  def self.call
    new.call
  end

  def initialize
    log_message "Initializing"
    secret_file = StringIO.new(google_secret.to_json)
    @session = GoogleDrive::Session.from_service_account_key(secret_file)
    @spreadsheet = @session.spreadsheet_by_key(spreadsheet_key)
  end

  def call
    @rows = []
    archive_previous
    create_sheet1
    build_rows_from_digest(digest_ids)
    update_and_save_worksheet
    clear_archive
  end

private

  def log_message(message)
    message = "Digest::Exporter :: #{message}"
    message = Time.zone.now.strftime("%F %T.%L ") + message if Rails.env.development?
    Rails.logger.info message
  end

  def archive_previous
    log_message "archive_previous"
    @yesterday = @spreadsheet.worksheets[0]
    archive_title = "Archive#{@yesterday.num_cols.positive? ? " #{@yesterday[1, @yesterday.num_cols]}".downcase : ''}"
    log_message "Saving archived sheet as #{archive_title}"
    @yesterday.title = archive_title
    @yesterday.save
  end

  def create_sheet1
    log_message "create_sheet1"
    @worksheet = @spreadsheet.add_worksheet("Sheet1", digest_ids.count, column_headers.count, index: 0)
  end

  def build_rows_from_digest(digest_ids)
    log_message "build_rows_from_digest"
    log_message "Adding #{column_headers.count + 1} column headers, ApplicationDigest.column_headers + extraction date, to @rows"
    @rows << [column_headers + extraction_date].flatten
    log_message "#{digest_ids.size} records to be added to @rows"
    digest_ids.each_with_index do |digest_id, _index|
      digest = ApplicationDigest.find(digest_id)
      @rows << digest.to_google_sheet_row
    end
    log_message "@row.count: #{@rows.size}"
  end

  def update_and_save_worksheet
    log_message "update_and_save_worksheet"
    log_message "updating cells, @rows.count: #{@rows.count}"
    @worksheet.update_cells(1, 1, @rows)
    log_message "saving worksheet"
    @worksheet.save
    raise SpreadsheetEmpty, "Spreadsheet unexpectedly empty" if @worksheet.rows.count == 1

    log_message "All records written and worksheet saved"
  rescue SpreadsheetEmpty => e
    log_message "Job thinks it succeeded but the spreadsheet is empty"
    AlertManager.capture_exception(e)
    raise
  end

  def clear_archive
    if @spreadsheet.worksheets.count < 2
      log_message "skipping clear_archive, only #{@spreadsheet.worksheets.count} worksheets"
    else
      log_message "clear_archive"
      @spreadsheet.worksheets[2..].each(&:delete)
    end
  end

  def digest_ids
    @digest_ids ||= initialize_digest_ids
  end

  def initialize_digest_ids
    log_message "initialize_digest_ids"
    ApplicationDigest.order(:created_at).pluck(:id)
  end

  def column_headers
    ApplicationDigest.column_headers
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
