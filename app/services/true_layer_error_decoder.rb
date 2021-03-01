class TrueLayerErrorDecoder
  # expects an array, the third item of which is a JSON-encoded hash
  #
  #  [
  #    "bank_data_import",
  #    "import_account_holders",
  #    "{\"TrueLayerError\" : {\"error_description\":\"<details of the error>\",\"error\":\"provider_error\",\"error_details\":{}}}"
  # ]
  #
  #
  ERROR_CODES = %w[
    provider_error
    account_permanently_locked
    account_temporarily_locked
    internal_server_error
    user_input_required
    wrong_credentials
  ].freeze

  def initialize(error_details)
    @error_hash = JSON.parse(error_details[2])
    @error_code = @error_hash.dig('TrueLayerError', 'error')
    return if @error_code.in?(ERROR_CODES)

    error_description = @error_hash.dig('TrueLayerError', 'error_description')
    Sentry.capture_message("Unknown error code received from TrueLayer: #{@error_code} :: #{error_description}")
    @error_code = 'unknown'
  end

  def error_heading
    I18n.t("true_layer_errors.headings.#{@error_code}")
  end

  def error_detail
    I18n.t("true_layer_errors.detail.#{@error_code}")
  end

  def show_link?
    @error_code != 'account_permanently_locked'
  end
end
