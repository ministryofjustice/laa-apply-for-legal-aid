module LinkedApplicationsHelper
  def all_linked_applications_details(legal_aid_application)
    return unless legal_aid_application.lead_application

    @all_linked_applications_details ||= sanitize(all_linked_applications(legal_aid_application)&.map { |application| "#{application.application_ref}, #{application.applicant.full_name}" }&.join("<br>"))
  end

private

  def all_linked_applications(legal_aid_application)
    all_associated_linked_applications(legal_aid_application).concat(all_lead_linked_applications(legal_aid_application)).excluding(legal_aid_application)
  end

  def all_associated_linked_applications(legal_aid_application)
    LinkedApplication.where(lead_application_id: legal_aid_application.lead_application.id, link_type_code: legal_aid_application.lead_linked_application.link_type_code).map(&:associated_application)
  end

  def all_lead_linked_applications(legal_aid_application)
    LinkedApplication.where(associated_application_id: legal_aid_application.lead_application.id, link_type_code: legal_aid_application.lead_linked_application.link_type_code).map(&:lead_application)
  end
end
