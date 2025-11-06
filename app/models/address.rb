class Address < ApplicationRecord
  belongs_to :applicant

  before_save :normalize_postcode

  def self.from_json(json)
    attrs = JSON.parse(json)
    new(attrs.slice("address_line_one", "address_line_two", "city", "county", "postcode", "lookup_id"))
  end

  def full_address
    [address_line_one, address_line_two, city, county, postcode, country_name?].compact.compact_blank.join(", ")
  end

  def pretty_postcode
    return unless postcode

    pretty_postcode? ? postcode : postcode.insert(-4, " ")
  end

  def pretty_postcode?
    postcode[-4] == " "
  end

  def country_name?
    country_name if include_country_name?
  end

  def include_country_name?
    country_name != "United Kingdom"
  end

  # NOTE: under the hood as_json method is called on the model first when you call to_json
  # so we override this method.
  # see https://api.rubyonrails.org/classes/ActiveModel/Serializers/JSON.html#method-i-as_json
  def as_json(options = {})
    super(
      only: %i[
        address_line_one
        address_line_two
        city
        county
        postcode
        lookup_id
      ],
      **options,
    )
  end

  def care_of_recipient
    if care_of == "person"
      "#{care_of_first_name} #{care_of_last_name}"
    elsif care_of == "organisation"
      care_of_organisation_name
    end
  end

private

  def normalize_postcode
    return if postcode.blank?

    postcode.delete!(" ")
    postcode.upcase!
  end
end
