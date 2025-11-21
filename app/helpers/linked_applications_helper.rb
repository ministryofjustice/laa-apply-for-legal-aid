module LinkedApplicationsHelper
  def all_linked_applications_details(legal_aid_application)
    return unless legal_aid_application.lead_application

    @all_linked_applications_details ||= sanitize(all_linked_applications(legal_aid_application)&.map { |application| "#{application.application_ref}, #{application.applicant.full_name}" }&.join("<br>"))
  end

private

  def all_linked_applications(legal_aid_application)
    all_linked_applications = LinkedApplication
                                .where(
                                  associated_application_id: legal_aid_application.lead_application.id,
                                  link_type_code: legal_aid_application.lead_linked_application&.link_type_code,
                                )
                                .or(
                                  LinkedApplication
                                    .where(
                                      lead_application_id: legal_aid_application.lead_application.id,
                                      link_type_code: legal_aid_application.lead_linked_application&.link_type_code,
                                    ),
                                )

    all_linked_applications.map(&:associated_application).concat(all_linked_applications.map(&:lead_application)).excluding(legal_aid_application, legal_aid_application.target_application).reject(&:discarded?).uniq
  end
end
