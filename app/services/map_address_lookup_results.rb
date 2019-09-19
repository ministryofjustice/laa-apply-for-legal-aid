class MapAddressLookupResults
  NUMBER = %w[SUB_BUILDING_NAME BUILDING_NUMBER].freeze
  NUMBER_NAME = %w[SUB_BUILDING_NAME BUILDING_NUMBER BUILDING_NAME].freeze
  NAME = %w[BUILDING_NAME].freeze
  FULL_NAME = %w[SUB_BUILDING_NAME BUILDING_NAME].freeze
  ROAD = %w[DEPENDENT_THOROUGHFARE_NAME THOROUGHFARE_NAME].freeze
  EVERYTHING = %w[SUB_BUILDING_NAME BUILDING_NUMBER BUILDING_NAME DEPENDENT_THOROUGHFARE_NAME THOROUGHFARE_NAME].freeze

  def self.call(results)
    results.map do |result|
      result['DPA'] && map_to_address(result['DPA'])
    end
  end

  def self.combine_number(result)
    result.slice(*NUMBER).values.compact.join(', ')
  end

  def self.combine_number_name(result)
    result.slice(*NUMBER_NAME).values.compact.join(', ')
  end

  def self.combine_full_name(result)
    result.slice(*FULL_NAME).values.compact.join(', ')
  end

  def self.combine_road(result)
    result.slice(*ROAD).values.compact.join(', ')
  end

  def self.combine_everything(result)
    result.slice(*EVERYTHING).values.compact.join(', ')
  end

  def self.combine_number_name_and_road(result)
    [combine_number_name(result), combine_road(result)].compact.join(' ')
  end

  def self.combine_number_and_name(result)
    [combine_number(result), result['BUILDING_NAME']].compact.join(' ')
  end

  def self.get_line_one(result)
    if result['BUILDING_NAME'].to_s.length < 9 && result['ORGANISATION_NAME'].nil? # no organisation or building name
      combine_number_name_and_road(result)
    elsif result['ORGANISATION_NAME'].nil? && result['BUILDING_NUMBER'].nil? # Building name exists, org doesn't, NO NUMBER
      combine_full_name(result)
    elsif result['ORGANISATION_NAME'].nil? # Building name exists, org doesn't, WITH NUMBER
      combine_number_and_name(result)
    else # Building name and org both exist # Organisation exists, we put it in address line 1 (where it can be edited), no building name
      result['ORGANISATION_NAME']
    end
  end

  def self.get_line_two(result)
    if result['BUILDING_NAME'].to_s.length < 9 && result['ORGANISATION_NAME'].nil? # no organisation or building name
      result['DEPENDENT_LOCALITY']
    elsif result['ORGANISATION_NAME'].nil? # Building name exists, org doesn't, WITH NUMBER
      combine_road(result)
    elsif result['BUILDING_NAME'].to_s.length < 9 # Organisation exists, we put it in address line 1 (where it can be edited), no building name
      combine_number_name_and_road(result)
    else # Building name and org both exist
      combine_everything(result)
    end
  end

  def self.map_to_address(result)
    line_one = get_line_one(result)
    line_two = get_line_two(result)
    Address.new(
      address_line_one: line_one,
      address_line_two: line_two,
      city: result['POST_TOWN'],
      county: '',
      postcode: result['POSTCODE'],
      lookup_id: result['UDPRN'] # Unique Delivery Point Reference Number
    )
  end
end
