module CheckProviderAnswersHelper
  def correspondence_address_change_link(legal_aid_application)
    if legal_aid_application.applicant.correspondence_address_choice.eql?("home")
      nil
    elsif legal_aid_application.applicant.correspondence_address_choice.eql?("office")
      providers_legal_aid_application_correspondence_address_manual_path(legal_aid_application)
    else
      providers_legal_aid_application_correspondence_address_lookup_path(legal_aid_application)
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
