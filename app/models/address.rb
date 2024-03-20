class Address < ApplicationRecord
  belongs_to :applicant

  before_save :normalize_postcode

  def self.from_json(json)
    attrs = JSON.parse(json)
    new(attrs.slice("address_line_one", "address_line_two", "city", "county", "postcode", "lookup_id"))
  end

  def full_address
    [address_line_one, address_line_two, city, county, postcode, country?].compact.compact_blank.join(", ")
  end

  def pretty_postcode
    return unless postcode

    pretty_postcode? ? postcode : postcode.insert(-4, " ")
  end

  def pretty_postcode?
    postcode[-4] == " "
  end

  def country?
    country if include_country?
  end

  def include_country?
    country != "GBR"
  end

  def to_json(*_args)
    {
      address_line_one:,
      address_line_two:,
      city:,
      county:,
      postcode:,
      lookup_id:,
    }.to_json
  end

private

  def normalize_postcode
    return if postcode.blank?

    postcode.delete!(" ")
    postcode.upcase!
  end
end
