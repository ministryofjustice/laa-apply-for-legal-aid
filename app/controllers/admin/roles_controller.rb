module Admin
  class RolesController < AdminBaseController
    def index
      @provider_firms = Firm.search(params[:search])
    end
  end
end
