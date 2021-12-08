module V1
  class LegalAidApplicationsController < ApiController
    def destroy
      legal_aid_application = LegalAidApplication.find(params[:id])
      if legal_aid_application
        legal_aid_application.discard
        legal_aid_application.scheduled_mailings.map(&:cancel!)

        render '', status: :ok
      else
        render '', status: :not_found
      end
    end
  end
end
