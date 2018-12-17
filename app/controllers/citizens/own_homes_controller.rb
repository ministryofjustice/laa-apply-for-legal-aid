module Citizens
  class OwnHomesController < BaseController
    def show
      @form = LegalAidApplications::OwnHomeForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::OwnHomeForm.new(form_params)

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

    def own_home_params
      params.fetch(:legal_aid_application, {}).permit(:own_home)
    end

    def form_params
      own_home_params.merge(model: legal_aid_application)
    end

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end
  end
end
