module Citizens
  class InformationController < BaseController
    include Flowable

    def show
      legal_aid_application
    end

    private

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end
  end
end
