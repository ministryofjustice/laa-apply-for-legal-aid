class Address < ApplicationRecord
  belongs_to :applicant

  validates :city, :postcode, presence: true

  before_validation :normalize_postcode

  validates :postcode, format: { with: POSTCODE_REGEXP }
  validate :validate_address_lines

  def self.from_json(json)
    attrs = JSON.parse(json)
    new(attrs.slice("address_line_one", "address_line_two", "city", "county", "postcode", "lookup_id"))
  end

  def full_address
    [address_line_one, address_line_two, city, county, postcode].compact.compact_blank.join(", ")
  end

  def pretty_postcode
    pretty_postcode? ? postcode : postcode.insert(-4, " ")
  end

  def pretty_postcode?
    postcode[-4] == " "
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

  def validate_address_lines
    return if address_line_one.present? || address_line_two.present?

    errors.add(:address_line_one, :blank)
  end

  def normalize_postcode
    return if postcode.blank?

    postcode.delete!(" ")
    postcode.upcase!
  end
end
