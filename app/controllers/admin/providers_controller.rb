module Admin
  class ProvidersController < ApplicationController
    before_action :authenticate_admin_user!
    before_action :new_provider, only: %i[check create]
    layout 'admin'.freeze

    def new
      @provider = Provider.new
    end

    def check
      service = ProviderDetailsService.new(@provider)
      if service.check == :success
        @firm_name = service.firm_name
        render :check
      else
        @provider.errors[:username] << service.message
        render :new
      end
    end

    def create
      service = ProviderDetailsService.new(@provider)
      if service.create == :success
        flash.notice = "User #{@provider.username} created"
        redirect_to new_admin_provider_path
      else
        @provider.errors[:username] << service.message
        render :new
      end
    end

    private

    def new_provider
      @provider = Provider.new(username: params[:provider][:username].downcase)
    end
  end
end
