module Providers
  class HasOtherProceedingsController < ProviderBaseController
    def show
      return go_forward unless Setting.allow_multiple_proceedings?

      proceeding_types
    end

    def update
      return continue_or_draft if draft_selected?

      if params[:has_other_proceeding].in?(%w[true false])
        go_forward(params[:has_other_proceeding] == 'true')
      else
        @error = { 'has_other_proceeding-error' => I18n.t('providers.has_other_proceedings.show.error') }
        render :show
      end
    end

    def destroy
      remove_proceeding

      if proceeding_types.empty?
        redirect_to providers_legal_aid_application_proceedings_types_path
      else
        render :show
      end
    end

    private

    def proceeding_types
      @proceeding_types ||= legal_aid_application.proceeding_types
    end

    def proceeding_type_id
      proceeding_types.find_by(code: form_params)&.id
    end

    def proceeding_type
      ApplicationProceedingType.find_by(
        legal_aid_application_id: legal_aid_application.id,
        proceeding_type_id: proceeding_type_id
      )
    end

    def remove_proceeding
      ActiveRecord::Base.transaction do
        proceeding_type&.destroy!
        # legal_aid_application.clear_scopes!
        # AddScopeLimitationService.call(legal_aid_application, :substantive) if proceeding_types.any?
      end
    end

    def form_params
      params.require(:id)
    end
  end
end
