module Citizens
  class StudentFinancesController < CitizenBaseController
    def show
      @form = LegalAidApplications::StudentFinanceForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::StudentFinanceForm.new(form_params)

      if @form.save
        case params[:student_finance]
        when 'yes'
          render html: '<div>html YES here</div>'.html_safe
        when 'no'
        # legal_aid_application.student_finance? go_forward
          render html: '<div>html NO here</div>'.html_safe
        end
      else
        render :show
      end
    end

    # def update
    #   case params[:student_finance]
    #   when 'yes'
    #     go_forward
    #     # redirect_to providers_legal_aid_applications_path
    #   when 'no'
    #     redirect_to providers_select_office_path
    #   else
    #     render :show
    #   end
    # end

    private

    def form_params
      merge_with_model(legal_aid_application) do
        next {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:student_finance)
      end
    end

    def irregular_income
      @irregular_income = legal_aid_application.irregular_incomes
    end
  end
end



