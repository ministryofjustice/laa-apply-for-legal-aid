# frozen_string_literal: true

class BankHolidayRetriever
  UnsuccessfulRetrievalError = Class.new(StandardError)
  DEFAULT_GROUP = "england-and-wales"

  def self.dates(group: DEFAULT_GROUP)
    new.dates(group)
  end

  def data
    return raise_error unless response.success?

    @data ||= JSON.parse(response.body)
  end

  def dates(group)
    return if data.empty?

    data.dig(group, "events")&.pluck("date")
  end

private

  def response
    @response ||= conn.get
  rescue StandardError => e
    Rails.logger.error("#{self.class.name} error: #{e.class}, #{e.message}")
    raise
  end

  def conn
    @conn ||= Faraday.new(url:, headers:)
  end

  def url
    Rails.configuration.x.bank_holidays_url
  end

  def headers
    {
      "User-Agent" => "CivilApply/#{HostEnv.environment || 'host-env-missing'} Faraday/#{Faraday::VERSION}",
      "Accept" => "application/json",
    }
  end

  def raise_error
    raise UnsuccessfulRetrievalError, "Retrieval Failed: #{response.status} #{response.reason_phrase}"
  end
end
