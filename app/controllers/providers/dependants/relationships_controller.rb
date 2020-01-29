module Providers
  module Dependants
    class RelationshipsController < ProviderBaseController
      prefix_step_with :dependants

      def show
        @form = DependantForm::RelationshipForm.new(model: dependant)
      end

      def update
        @form = DependantForm::RelationshipForm.new(form_params)

        if @form.save
          go_forward(dependant)
        else
          render :show
        end
      end

      private

      def dependant
        @dependant ||= legal_aid_application.dependants.find(params[:dependant_id])
      end

      def form_params
        merge_with_model(dependant) do
          next {} unless params[:dependant]

          params.require(:dependant).permit(:relationship)
        end
      end
    end
  end
end
