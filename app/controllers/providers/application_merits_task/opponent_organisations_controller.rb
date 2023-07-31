module Providers
  module ApplicationMeritsTask
    class OpponentOrganisationsController < ProviderBaseController
      def show
        @form = Opponents::OrganisationForm.new(model: opponent, name: opponent.name, ccms_code: opponent.ccms_code, description: opponent.description)
      end

      def new
        @organisation_types = organisation_types
        @form = Opponents::OrganisationForm.new(model: opponent)
      end

      #   def update
      #     @form = Opponents::OrganisationForm.new(form_params)
      #     render :show unless update_task_save_continue_or_draft(:application, :opponent_name)
      #   end

    private

      def opponent
        @opponent ||= existing_opponent || build_new_opponent
      end

      def existing_opponent
        legal_aid_application.opponents.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        nil
      end

      def build_new_opponent
        ::ApplicationMeritsTask::Organisation.new.build_opponent(legal_aid_application:)
      end

      def form_params
        merge_with_model(opponent) do
          params.require(:application_merits_task_opponent).permit(
            :name, :description, :ccms_code
          )
        end
      end

      def organisation_types
        [
          { "ccms_code" => "CHAR", "description" => "Charity" },
          { "ccms_code" => "CO", "description" => "Court" },
          { "ccms_code" => "GOVT", "description" => "Government Department" },
          { "ccms_code" => "HMO", "description" => "HM Prison or Young Offender Institute" },
          { "ccms_code" => "HOA", "description" => "Housing Association" },
          { "ccms_code" => "IRC", "description" => "Immigration Removal Centre" },
          { "ccms_code" => "LTD", "description" => "Limited Company" },
          { "ccms_code" => "LLP", "description" => "Limited Liability Partnership" },
          { "ccms_code" => "LA", "description" => "Local Authority" },
          { "ccms_code" => "NHS", "description" => "National Health Service" },
          { "ccms_code" => "PART", "description" => "Partnership" },
          { "ccms_code" => "POLICE", "description" => "Police Authority" },
          { "ccms_code" => "PLC", "description" => "Public Limited Company" },
          { "ccms_code" => "SOLE", "description" => "Sole Trader" },
        ]
      end
    end
  end
end
