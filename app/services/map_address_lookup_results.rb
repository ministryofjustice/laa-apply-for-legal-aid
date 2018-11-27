class MapAddressLookupResults
  LINE_ONE_PARTS = %w[SUB_BUILDING_NAME BUILDING_NUMBER BUILDING_NAME].freeze
  LINE_TWO_PARTS = %w[DEPENDENT_THOROUGHFARE_NAME THOROUGHFARE_NAME].freeze

  def self.call(results)
    results.map do |result|
      result['DPA'] && map_to_address(result['DPA'])
    end
  end

  def self.map_to_address(result)
    Address.new(
      organisation: result['ORGANISATION_NAME'],
      address_line_one: result.slice(*LINE_ONE_PARTS).values.compact.join(', '),
      address_line_two: result.slice(*LINE_TWO_PARTS).values.compact.join(', '),
      city: result['POST_TOWN'],
      postcode: result['POSTCODE'],
      lookup_id: result['UDPRN'] # Unique Delivery Point Reference Number
    )
  end
end
