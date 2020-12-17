module Admin
  class ProvidersController < AdminBaseController
    before_action :new_provider, only: %i[check create]

    def new
      @provider = Provider.new
    end

    def index
      if params[:firm_id] == '0'
        @providers = Provider.order(:username)
        @firm = nil
      else
        @firm = Firm.find(params[:firm_id])
        @providers = @firm.providers.order(:username)
      end
    end

    def check
      service = ProviderDetailsService.new(@provider)
      if service.check == :success
        @firm_name = service.firm_name
        render :check
      else
        @provider.errors.add(:username, service.message)
        render :new
      end
    end

    def create
      service = ProviderDetailsService.new(@provider)
      if service.create == :success
        flash.notice = "User #{@provider.username} created"
        redirect_to new_admin_provider_path
      else
        @provider.errors.add(:username, service.message)
        render :new
      end
    end

    private

    def new_provider
      @provider = Provider.new(username: params[:provider][:username].upcase)
    end
  end
end
