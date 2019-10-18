class MapAddressLookupResults
  NUMBER = %w[SUB_BUILDING_NAME BUILDING_NUMBER].freeze
  NUMBER_NAME = %w[SUB_BUILDING_NAME BUILDING_NAME BUILDING_NUMBER].freeze
  FULL_NAME = %w[SUB_BUILDING_NAME BUILDING_NAME].freeze
  ROAD = %w[DEPENDENT_THOROUGHFARE_NAME THOROUGHFARE_NAME].freeze

  def self.call(results)
    results.map do |result|
      result['DPA'] && map_to_address(result['DPA'])
    end
  end

  def self.building_name(result)
    result['BUILDING_NAME']
  end

  def self.organisation_name(result)
    result['ORGANISATION_NAME']
  end

  def self.building_number(result)
    result['BUILDING_NUMBER']
  end

  def self.thoroughfare_name(result)
    result['THOROUGHFARE_NAME']
  end

  def self.dependent_locality(result)
    result['DEPENDENT_LOCALITY']
  end

  def self.combine(result, *attr)
    result.slice(*attr).values.compact.join(', ')
  end

  def self.combine_with_road(result, *attr, separator)
    [combine(result, *attr), combine(result, *ROAD)].compact.join(separator).strip
  end

  def self.use_dependent_locality?(result)
    (building_name(result).to_s.length < 9 && organisation_name(result).nil?) ||
      ((building_name(result).to_s.length < 9 || organisation_name(result).nil?) && thoroughfare_name(result).nil?)
  end

  def self.get_line_one(result)
    return combine_with_road(result, *NUMBER_NAME, ' ') if building_name(result).to_s.length < 9 && organisation_name(result).nil?
    return combine(result, *FULL_NAME) if organisation_name(result).nil?

    organisation_name(result)
  end

  def self.get_line_two(result)
    return dependent_locality(result) if use_dependent_locality?(result)
    return combine_with_road(result, *NUMBER, ' ') if organisation_name(result).nil?
    return combine_with_road(result, *FULL_NAME, ', ') if building_number(result).nil? && building_name(result) && thoroughfare_name(result)

    combine_with_road(result, *NUMBER_NAME, ' ')
  end

  def self.map_to_address(result)
    line_one = get_line_one(result)
    line_two = get_line_two(result)
    Address.new(
      address_line_one: line_one,
      address_line_two: line_two,
      city: result['POST_TOWN'],
      county: nil,
      postcode: result['POSTCODE'],
      lookup_id: result['UDPRN'] # Unique Delivery Point Reference Number
    )
  end
end
