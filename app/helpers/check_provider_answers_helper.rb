module CheckProviderAnswersHelper
  def change_address_link(legal_aid_application, location)
    if location == "correspondence"
      return providers_legal_aid_application_correspondence_address_lookup_path(legal_aid_application.id, anchor: :postcode) if legal_aid_application.applicant&.address&.lookup_used?

      providers_legal_aid_application_correspondence_address_manual_path(legal_aid_application.id, anchor: :postcode)

    elsif location == "home"
      providers_legal_aid_application_home_address_status_path(legal_aid_application.id)
    end
  end

  def home_address_text(applicant)
    if applicant.same_correspondence_and_home_address?
      "Same as correspondence address"
    elsif applicant.no_fixed_residence?
      "No fixed residence"
    else
      address_with_line_breaks(applicant.home_address)
    end
  end
end
