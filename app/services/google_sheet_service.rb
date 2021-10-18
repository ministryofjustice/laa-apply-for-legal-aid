class GoogleSheetService
  def self.call
    new.call
  end

  def initialize
    secret_file = StringIO.new(google_secret.to_json)
    session = GoogleDrive::Session.from_service_account_key(secret_file)
    @ws = session.spreadsheet_by_key("1dXnEdiqqP_fOeWzDsbXY83lwwK8pvf8j4jsUqaGnGMs").worksheets[0]
    delete_existing_data
  end

  def call
    ApplicationDigest.all.each_with_index { |digest, index| write_to_sheet(digest.to_google_sheet_row, index) }
    @ws.save
    puts '  '
  end

  private

  def delete_existing_data
    @ws.delete_rows(2, @ws.max_rows - 1)
    @ws.save
  end

  def write_to_sheet(row, index)
    @ws.insert_rows(index+2, [row])
    print '.'
  end

  def google_secret
    {
      type: 'service_account',
      project_id: 'laa-apply-for-legal-aid',
      private_key_id: ENV['GOOGLE_SHEETS_PRIVATE_KEY_ID'],
      private_key: ENV['GOOGLE_SHEETS_PRIVATE_KEY'],
      client_email: ENV['GOOGLE_SHEETS_CLIENT_EMAIL'],
      client_id: ENV['109643562093060480241'],
      auth_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_uri: 'https://oauth2.googleapis.com/token',
      auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
      client_x509_cert_url: 'https://www.googleapis.com/robot/v1/metadata/x509/laa-apply-service%40laa-apply-for-legal-aid.iam.gserviceaccount.com'
    }
  end

end

