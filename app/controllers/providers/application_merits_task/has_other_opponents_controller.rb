module Providers
  module ApplicationMeritsTask
    class HasOtherOpponentsController < ProviderBaseController
      def show
        return redirect_to providers_legal_aid_application_opponent_type_path(legal_aid_application) unless opponents.any?

        @form = LegalAidApplications::HasOtherOpponentsForm.new(model: legal_aid_application)
      end

      def update
        @form = LegalAidApplications::HasOtherOpponentsForm.new(form_params)
        update_task(:application, :opponent_name)
        return continue_or_draft if draft_selected?
        return go_forward(@form.has_other_opponents?) if @form.valid?

        render :show
      end

      def destroy
        opponent.destroy!
        flash[:moj_success] = I18n.t("providers.has_other_opponents.show.removed", name: opponent.full_name)
        return redirect_to providers_legal_aid_application_opponent_type_path(legal_aid_application) unless opponents.any?

        @form = LegalAidApplications::HasOtherOpponentsForm.new(model: legal_aid_application)
        render :show
      end

    private

      def task_list_should_update?
        application_has_task_list? && @form.valid? && !draft_selected? && !@form.has_other_opponents?
      end

      def opponents
        legal_aid_application.opponents
      end

      def opponent
        @opponent ||= opponents&.find(form_params[:opponent_id])
      end

      def form_params
        params[:action] == "destroy" ? destroy_form_params : update_form_params
      end

      def destroy_form_params
        params.permit(:opponent_id)
      end

      def update_form_params
        merge_with_model(legal_aid_application) do
          return {} unless params[:legal_aid_application]

          params.expect(legal_aid_application: [:has_other_opponents])
        end
      end
    end
  end
end
