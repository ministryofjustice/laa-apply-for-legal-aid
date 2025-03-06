module Providers
  module Means
    module CapitalDisregards
      class MandatoryController < ProviderBaseController
        prefix_step_with :capital_disregards

        def show
          @form = Providers::Means::CapitalDisregards::MandatoryForm.new(model: legal_aid_application)
        end

        def update
          @form = Providers::Means::CapitalDisregards::MandatoryForm.new(form_params)
          return continue_or_draft if draft_selected?

          if @form.valid?
            @form.save!
            go_forward(@legal_aid_application.next_incomplete_mandatory_disregard)
          else
            render :show
          end
        end

      private

        def form_params
          merge_with_model(legal_aid_application) do
            params
                  .expect(providers_means_capital_disregards_mandatory_form: [:none_selected, { mandatory_capital_disregards: [] }])
                  .merge(legal_aid_application:)
          end
        end
      end
    end
  end
end
