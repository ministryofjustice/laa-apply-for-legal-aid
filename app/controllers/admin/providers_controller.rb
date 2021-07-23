module Admin
  class ProvidersController < AdminBaseController
    def index
      if params[:firm_id] == '0'
        @providers = Provider.order(:username)
        @firm = nil
      else
        @firm = Firm.find(params[:firm_id])
        @providers = @firm.providers.order(:username)
      end
    end
  end
end
