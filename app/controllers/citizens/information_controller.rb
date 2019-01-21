module Citizens
  class InformationController < ApplicationController
    include Flowable
    
    def show
      legal_aid_application
    end

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end
  end
end
