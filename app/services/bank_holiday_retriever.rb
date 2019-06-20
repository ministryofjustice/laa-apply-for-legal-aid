# frozen_string_literal: true

class BankHolidayRetriever
  UnsuccessfulRetrievalError = Class.new(StandardError)
  API_URL = 'https://www.gov.uk/bank-holidays.json'
  DEFAULT_GROUP = 'england-and-wales'

  def self.dates
    new.dates(DEFAULT_GROUP)
  end

  def data
    return raise_error unless response.is_a?(Net::HTTPOK)

    @data ||= JSON.parse(response.body)
  end

  def dates(group)
    return if data.empty?

    data.dig(group, 'events')&.pluck('date')
  end

  private

  def response
    @response ||= Net::HTTP.get_response(uri)
  end

  def uri
    URI.parse(API_URL)
  end

  def raise_error
    raise UnsuccessfulRetrievalError, "Retrieval Failed: #{response.message} (#{response.code}) #{response.body}"
  end
end
