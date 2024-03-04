class BaseAddressSelectionForm < BaseForm
  before_validation :deserialize_address

  validate :lookup_id_present

  def initialize(*args)
    super
    attributes[:lookup_used] = true
  end

private

  def deserialize_address
    return if lookup_id.blank?

    attributes[:address_line_one] = selected_address.address_line_one
    attributes[:address_line_two] = selected_address.address_line_two
    attributes[:city] = selected_address.city
    attributes[:county] = selected_address.county
    attributes[:lookup_id] = selected_address.lookup_id
  end

  def exclude_from_model
    %i[addresses]
  end

  def selected_address
    @selected_address ||= addresses.find { |address| address.lookup_id == lookup_id }
  end

  def lookup_id_present
    return if lookup_id.present?

    errors.add(:lookup_id, I18n.t("activemodel.errors.models.address.attributes.lookup_id.blank", location:))
  end
end
