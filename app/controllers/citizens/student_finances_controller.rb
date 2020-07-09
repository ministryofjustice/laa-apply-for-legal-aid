module Citizens
  class StudentFinancesController < CitizenBaseController
    def show
      @form = LegalAidApplications::StudentFinanceForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::StudentFinanceForm.new(form_params)

      if @form.save
        go_forward
      else
        render :show
      end
    end

    private

    def form_params
      merge_with_model(legal_aid_application) do
        next {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:student_finance)
      end
    end
  end
end
