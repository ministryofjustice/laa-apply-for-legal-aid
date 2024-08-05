module CheckProviderAnswersHelper
  def change_address_link(legal_aid_application, location)
    if location == "correspondence"
      providers_legal_aid_application_correspondence_address_choice_path(legal_aid_application.id)
    elsif location == "home"
      providers_legal_aid_application_home_address_status_path(legal_aid_application.id)
    end
  end

  def client_has_home_address?(applicant)
    !applicant.no_fixed_residence?
  end

  def correspondence_address_text(applicant)
    if applicant.same_correspondence_and_home_address? && applicant.home_address.present?
      address_with_line_breaks(applicant.home_address)
    else
      address_with_line_breaks(applicant.address)
    end
  end
end
