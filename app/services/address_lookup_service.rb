class AddressLookupService
  prepend SimpleCommand

  ORDNANCE_SURVEY_URL = 'https://api.os.uk/search/places/v1/postcode'.freeze

  attr_reader :postcode

  def initialize(postcode)
    @postcode = postcode
  end

  def call
    MapAddressLookupResults.call(results)
  end

  private

  def query_params
    {
      key: Rails.configuration.x.ordnanace_survey_api_key,
      postcode: postcode,
      lr: 'EN'
    }
  end

  def results
    @results ||= perform_lookup
  end

  def perform_lookup
    uri = URI.parse(ORDNANCE_SURVEY_URL)
    uri.query = query_params.to_query
    response = Faraday.get(uri)

    if response.success?
      parse_successful_response(response)
    else
      record_error(:unsuccessful, StandardError.new(response.body))
      []
    end
  rescue Faraday::ConnectionFailed => e
    record_error(:service_unavailable, e)
    []
  end

  def parse_successful_response(response)
    parsed_body = JSON.parse(response.body)
    if parsed_body.dig('header', 'totalresults').positive?
      parsed_body['results']
    else
      errors.add(:lookup, :no_results)
      []
    end
  end

  def record_error(state, error)
    errors.add(:lookup, state)
    Sentry.capture_exception(error) unless POSTCODE_REGEXP.match?(@postcode) && state == :unsuccessful
  end
end
