module Providers
  module ApplicationMeritsTask
    class OpponentExistingOrganisationsController < ProviderBaseController
      def index
        organisations
      end

      def create
        return continue_or_draft if draft_selected?

        if duplicate_organisation?
          legal_aid_application.errors.add(:"organisation-search-input", t(".unique_organisation"))
          organisations
          render :index
        elsif add_organisation
          go_forward
        else
          legal_aid_application.errors.add(:"organisation-search-input", t(".search_and_select"))
          organisations
          render :index
        end
      end

    private

      def duplicate_organisation?
        legal_aid_application.opponents.where(ccms_opponent_id: form_params).any?
      rescue ActionController::ParameterMissing
        false
      end

      def add_organisation
        organisation_to_add = organisations.find { |org| org.ccms_opponent_id == form_params }
        add_organisation_service.call(organisation_to_add)
      rescue ActionController::ParameterMissing
        false
      end

      def add_organisation_service
        LegalFramework::AddOpponentOrganisationService.new(legal_aid_application)
      end

      def form_params
        params.require(:id)
      end

      def organisations
        @organisations ||= ::LegalFramework::Organisations::All.call
      end
    end
  end
end
