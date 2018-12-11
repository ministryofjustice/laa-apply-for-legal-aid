module Citizens
  class OwnHomesController < BaseController
    def show
      @legal_aid_application = LegalAidApplication.find(session[:current_application_ref])
      @form = Citizens::OwnHomeForm.new(current_params)
    end

    def update
      @legal_aid_application = LegalAidApplication.find(session[:current_application_ref])
      @form = Citizens::OwnHomeForm.new(form_params)

      if @form.save
        if @form.own_home == 'no'
          render plain: 'Navigate to question 2a; Do you have any savings or investments'
        else
          redirect_to citizens_property_value_path
        end
      else
        @legal_aid_application = LegalAidApplication.find(session[:current_application_ref])
        render :show
      end
    end

    private

    def current_params
      @legal_aid_application.attributes.symbolize_keys.slice(:own_home)
    end

    def own_home_params
      params.fetch(:legal_aid_application, {}).permit(:own_home)
    end

    def form_params
      own_home_params.merge(model: @legal_aid_application)
    end
  end
end
