module Task
  class MakeLink < Base
    def path
      if application.lead_linked_application.present?
        if application.lead_linked_application.lead_application_id.nil?
          Flow::Steps::LinkedApplications::FindLinkStep.path.call(application)
        elsif !application.lead_linked_application.confirm_link
          Flow::Steps::LinkedApplications::ConfirmLinkStep.path.call(application)
        elsif application.lead_linked_application.link_type_code == "FC_LEAD" && !application.linked_application_completed
          Flow::Steps::LinkedApplications::CopyStep.path.call(application)
        end
      else
        Flow::Steps::LinkedApplications::MakeLinkStep.path.call(application)
      end
    end
  end
end
