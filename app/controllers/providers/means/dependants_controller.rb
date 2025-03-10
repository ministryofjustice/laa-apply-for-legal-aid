module Providers
  module Means
    class DependantsController < ProviderBaseController
      def show
        @form = LegalAidApplications::DependantForm.new(model: dependant)
      end

      def new
        @form = LegalAidApplications::DependantForm.new(model: dependant)
      end

      def update
        @form = LegalAidApplications::DependantForm.new(form_params)
        render new_or_show unless save_continue_or_draft(@form)
      end

    private

      def dependant
        @dependant ||= dependant_exists? || build_new_dependant
      end

      def dependant_exists?
        legal_aid_application.dependants.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        false
      end

      def build_new_dependant
        Dependant.new(
          legal_aid_application:,
          number: legal_aid_application.dependants.count + 1,
        )
      end

      def form_params
        merged_params = merge_with_model(dependant) do
          params.expect(dependant: [*LegalAidApplications::DependantForm::MODEL_ATTRIBUTES])
        end
        convert_date_params(merged_params)
      end

      def new_or_show
        @form.model.id.nil? ? :new : :show
      end
    end
  end
end
