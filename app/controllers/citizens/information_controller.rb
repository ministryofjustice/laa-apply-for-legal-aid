module Citizens
  class InformationController < BaseController
    include ApplicationFromSession

    def show
      legal_aid_application
    end
  end
end
