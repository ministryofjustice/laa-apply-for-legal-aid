module CFE
  module SharedGoogleSheet
    SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

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
