module CheckProviderAnswersHelper
  def change_address_link(legal_aid_application, location)
    if location == "correspondence"
      return providers_legal_aid_application_correspondence_address_choice_path(legal_aid_application.id) if Setting.home_address?
      return providers_legal_aid_application_correspondence_address_lookup_path(legal_aid_application.id, anchor: :postcode) if legal_aid_application.applicant&.address&.lookup_used?

      providers_legal_aid_application_correspondence_address_choice_path(legal_aid_application.id, anchor: :postcode)

    elsif location == "home"
      providers_legal_aid_application_home_address_status_path(legal_aid_application.id)
    end
  end

  def client_has_home_address?(applicant)
    !applicant.no_fixed_residence?
  end

  def correspondence_address_text(applicant)
    if Setting.home_address? && applicant.same_correspondence_and_home_address? && applicant.home_address.present?
      # TODO: Just delete the `Setting.home_address? &&` from this
      # block when the home_address? flag is removed
      address_with_line_breaks(applicant.home_address)
    else
      address_with_line_breaks(applicant.address)
    end
  end
end
