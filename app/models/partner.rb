class Partner < ApplicationRecord
  belongs_to :legal_aid_application, dependent: :destroy

  def pretty_postcode
    pretty_postcode? ? postcode : postcode.insert(-4, " ")
  end

  def pretty_postcode?
    postcode[-4] == " "
  end

  def duplicate_applicants_address
    update!(
      address_line_one: applicants_address.address_line_one,
      address_line_two: applicants_address.address_line_two,
      city: applicants_address.city,
      county: applicants_address.county,
      postcode: applicants_address.postcode,
      organisation: applicants_address.organisation,
    )
  end

  def clear_stored_address
    update!(
      address_line_one: nil,
      address_line_two: nil,
      city: nil,
      county: nil,
      postcode: nil,
      organisation: nil,
    )
  end

private

  def applicants_address
    @applicants_address ||= legal_aid_application.applicant.address
  end
end
