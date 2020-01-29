module Providers
  class HasDependantsController < ProviderBaseController
    def show
      @form = LegalAidApplications::HasDependantsForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::HasDependantsForm.new(form_params)
      if @form.save
        go_forward
      else
        render :show
      end
    end

    private

    def form_params
      merge_with_model(legal_aid_application) do
        return {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:has_dependants)
      end
    end
  end
end
