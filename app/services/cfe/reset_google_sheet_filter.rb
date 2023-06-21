module CFE
  class ResetGoogleSheetFilter
    include SharedGoogleSheet
    # NOTE: This is intended as a temporary class while we switch from CFE-Legacy to CFE-Civil
    # Once that change over is complete, the aim is that this can be removed, along with

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
    end

    def call
      reset_worksheet_filter
      log_message "Filter reset"
    end

  private

    def reset_worksheet_filter
      @spreadsheet = @sheet_service.get_spreadsheet(spreadsheet_key)
      requests = [{ clear_basic_filter: { sheet_id: @spreadsheet.sheets[0].properties.sheet_id } }]
      update_request = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(requests:)
      @sheet_service.batch_update_spreadsheet(spreadsheet_key, update_request)
    end
  end
end
