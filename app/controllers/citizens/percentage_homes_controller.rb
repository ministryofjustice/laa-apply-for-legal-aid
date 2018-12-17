module Citizens
  class PercentageHomesController < BaseController
    def show
      @form = LegalAidApplications::PercentageHomeForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::PercentageHomeForm.new(percentage_home_params.merge(model: legal_aid_application))

      if @form.save
        render plain: 'Navigate to question 2a. Do you have any savings or investments?'
      else
        render :show
      end
    end

    private

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end

    def percentage_home_params
      params.require(:legal_aid_application).permit(:percentage_home)
    end
  end
end
