module Providers
  module Means
    module CapitalDisregards
      class AddDetailsController < ProviderBaseController
        prefix_step_with :capital_disregards
        def show
          @form = AddDetailsForm.new(model: capital_disregard)
        end

        def update
          @form = AddDetailsForm.new(form_params)
          if @form.valid?
            @form.save!
            go_forward(next_disregard)
          else
            render :show
          end
        end

      private

        def next_disregard
          @capital_disregard.mandatory? ? @legal_aid_application.next_incomplete_mandatory_disregard : @legal_aid_application.next_incomplete_discretionary_disregard
        end

        def capital_disregard
          @capital_disregard = CapitalDisregard.find(capital_disregard_id_param)
        end

        def capital_disregard_id_param
          params.require(:id)
        end

        def form_params
          merged_params = merge_with_model(capital_disregard) do
            params.expect(capital_disregard: [:payment_reason, :amount, :account_name, :date_received])
          end
          convert_date_params(merged_params)
        end
      end
    end
  end
end
