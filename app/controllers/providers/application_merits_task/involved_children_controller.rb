module Providers
  module ApplicationMeritsTask
    class InvolvedChildrenController < ProviderBaseController
      def new
        @form = InvolvedChildForm.new(model: involved_child)
      end

      def show
        @form = InvolvedChildForm.new(model: involved_child)
      end

      def update
        app/views/providers/application_merits_task/has_other_involved_children/show.html.erb        @form = InvolvedChildForm.new(form_params)
        if @form.save
          go_forward(involved_child)
        else
          render @form.model.id.nil? ? :new : :show
        end
      end

      private

      def involved_child
        @involved_child ||= involved_child_exists? || build_new_involved_child
      end

      def involved_child_exists?
        legal_aid_application.involved_children.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        false
      end

      def build_new_involved_child
        ::ApplicationMeritsTask::InvolvedChild.new(
          legal_aid_application: legal_aid_application
        )
      end

      def form_params
        merged_params = merge_with_model(involved_child) do
          params.require(:application_merits_task_involved_child).permit(*InvolvedChildForm::MODEL_ATTRIBUTES)
        end
        convert_date_params(merged_params)
      end
    end
  end
end
