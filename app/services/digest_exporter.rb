class DigestExporter
  def self.call
    new.call
  end

  def initialize
    Rails.logger.info "Digest exporter starting"
    secret_file = StringIO.new(google_secret.to_json)
    @session = GoogleDrive::Session.from_service_account_key(secret_file)
    @worksheet = @session.spreadsheet_by_key(spreadsheet_key).worksheets[0]
    delete_existing_data
    write_header_row
  end

  def call
    digest_ids = ApplicationDigest.order(:created_at).pluck(:id)
    Rails.logger.info "Exporting #{digest_ids.size} ApplicationDigest records"
    digest_ids.each_with_index do |digest_id, index|
      digest = ApplicationDigest.find(digest_id)
      write_to_sheet(digest.to_google_sheet_row, index)
      Rails.logger.info "#{index} records written" if index % 500 == 0
    end
    @worksheet.save
    Rails.logger.info "All records written and worksheet saved"
  end

  private

  def delete_existing_data
    # You can't delete all the rows in a worksheet, so we delete all but one, and we'll overwrite that
    # with the column headers
    @worksheet.delete_rows(1, @worksheet.max_rows - 1)
    @worksheet.save
    Rails.logger.info "Existing data removed from spreadsheet"
  end

  def write_to_sheet(row, index)
    @worksheet.insert_rows(index + 2, [row])
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
      "Extracted at: #{Time.zone.now}"
    ]
  end

  def spreadsheet_key
    ENV['GOOGLE_SHEETS_SPREADSHEET_ID']
  end

  def google_secret
    {
      type: 'service_account',
      project_id: 'laa-apply-for-legal-aid',
      private_key_id: ENV['GOOGLE_SHEETS_PRIVATE_KEY_ID'],
      private_key: ENV['GOOGLE_SHEETS_PRIVATE_KEY_VALUE'],
      client_email: ENV['GOOGLE_SHEETS_CLIENT_EMAIL'],
      client_id: ENV['GOOGLE_SHEETS_CLIENT_ID'],
      auth_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_uri: 'https://oauth2.googleapis.com/token',
      auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
      client_x509_cert_url: 'https://www.googleapis.com/robot/v1/metadata/x509/laa-apply-service%40laa-apply-for-legal-aid.iam.gserviceaccount.com'
    }
  end
end
