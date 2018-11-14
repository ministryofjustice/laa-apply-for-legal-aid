class MapAddressLookupResults
  LINE_ONE_PARTS = %w[SUB_BUILDING_NAME BUILDING_NUMBER BUILDING_NAME].freeze
  LINE_TWO_PARTS = %w[DEPENDENT_THOROUGHFARE_NAME THOROUGHFARE_NAME].freeze

  def self.call(results)
    results.map do |result|
      result['DPA'] && map_to_address(result['DPA'])
    end
  end

  def self.map_to_address(result)
    line_one_parts = LINE_ONE_PARTS.each_with_object([]) do |part, mem|
      mem << result[part]
    end
    line_two_parts = LINE_TWO_PARTS.each_with_object([]) do |part, mem|
      mem << result[part]
    end

    Address.new(
      organisation: result['ORGANISATION_NAME'],
      address_line_one: line_one_parts.compact.join(', '),
      address_line_two: line_two_parts.compact.join(', '),
      city: result['POST_TOWN'],
      postcode: result['POSTCODE']
    )
  end
end
