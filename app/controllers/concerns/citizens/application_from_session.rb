module Citizens
  module ApplicationFromSession
    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_id])
    end
  end
end
