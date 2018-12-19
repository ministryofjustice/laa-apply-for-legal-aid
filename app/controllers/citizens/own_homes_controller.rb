module Citizens
  class OwnHomesController < BaseController
    include Flowable

    def show
      @form = LegalAidApplications::OwnHomeForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::OwnHomeForm.new(form_params)

      if @form.save
        go_forward
      else
        render :show
      end
    end

    private

    def own_home_params
      return {} unless params[:legal_aid_application]

      params.require(:legal_aid_application).permit(:own_home)
    end

    def form_params
      own_home_params.merge(model: legal_aid_application)
    end

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end
  end
end
