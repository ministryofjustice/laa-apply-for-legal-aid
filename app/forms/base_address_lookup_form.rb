class BaseAddressLookupForm < BaseForm
  before_validation :normalise_postcode

  EDIT_DETAILS = EditStruct.new(section: :client_case_details, task: :client_details, application_path: "legal_aid_application")

  validates :postcode, presence: true, unless: :draft?
  validates :postcode, format: { with: POSTCODE_REGEXP, allow_blank: true }

  def save_as_draft
    @draft = true
    save!
  end

private

  def normalise_postcode
    return if postcode.blank?

    postcode.delete!(" ")
    postcode.upcase!
  end
end
