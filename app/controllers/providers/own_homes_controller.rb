module Providers
  class OwnHomesController < ApplicationController
    include Providers::ApplicationDependable
    def show
      @form = LegalAidApplications::OwnHomeForm.new(current_params)
    end

    def update
      @form = LegalAidApplications::OwnHomeForm.new(form_params)

      if @form.save
        if @form.own_home_no?
          render plain: 'Holding page: 1b Property Value'
        else
          render plain: 'Holding page: Navigate to question 2a; Do you have any savings or investments'
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
