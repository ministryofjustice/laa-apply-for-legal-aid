# :nocov:
module Citizens
  class PercentageHomesController < CitizenBaseController
    def show
      @form = LegalAidApplications::PercentageHomeForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::PercentageHomeForm.new(percentage_home_params)

      if @form.save
        go_forward
      else
        render :show
      end
    end

    private

    def percentage_home_params
      merge_with_model(legal_aid_application) do
        return {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:percentage_home)
      end
    end
  end
end
# :nocov:
