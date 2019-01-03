module CheckProviderAnswersHelper
  def change_address_link(applicant)
    return providers_legal_aid_application_address_lookup_path(anchor: :postcode) if applicant.address&.lookup_used?

    providers_legal_aid_application_address_path(anchor: :postcode)
  end
end
