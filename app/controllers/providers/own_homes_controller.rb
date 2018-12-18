module Providers
  class OwnHomesController < ApplicationController
    include ApplicationDependable
    include Steppable
    def show
      @form = LegalAidApplications::OwnHomeForm.new(current_params)
    end

    def update
      @form = LegalAidApplications::OwnHomeForm.new(form_params)

      if @form.save
        if @form.own_home_no?
          render plain: 'Holding page: 2a. Does your client have any savings or investments?'
        else
          render plain: 'Holding page: 1b. How much is your client’s home worth'
        end
      else
        render :show
      end
    end

    private

    def current_params
      legal_aid_application.attributes.symbolize_keys.slice(:own_home)
    end

    def own_home_params
      return {} unless params[:legal_aid_application]

      params.require(:legal_aid_application).permit(:own_home)
    end

    def form_params
      own_home_params.merge(model: legal_aid_application)
    end
  end
end
