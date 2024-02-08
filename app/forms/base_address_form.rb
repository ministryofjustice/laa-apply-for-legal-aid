class BaseAddressForm < BaseForm
  before_validation :normalise_postcode

  validates :address_line_one, :city, :postcode,
            presence: true,
            unless: :draft?

  validates :postcode, format: { with: POSTCODE_REGEXP, allow_blank: true }
  validates :city, :county, format: { with: /\A[A-Za-z ]*\z/, allow_blank: true }

  def exclude_from_model
    %i[lookup_postcode lookup_error]
  end

  def initialize(*args)
    super
    attributes[:lookup_used] = lookup_postcode.present?
  end

private

  def normalise_postcode
    return if postcode.blank?

    postcode.delete!(" ")
    postcode.upcase!
  end
end
