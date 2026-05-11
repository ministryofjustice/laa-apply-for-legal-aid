# :nocov:
module Test
  # This controller is used to render the payload that would be sent to the datastore.
  #
  # The test_datastore_payloads_xxx_path(s) route are defined in development only
  #
  class DatastorePayloadsController < ApplicationController
    before_action :authenticate_provider!
    before_action :legal_aid_application

    def application_as_json
      respond_to do |format|
        format.json { render json: LegalAidApplicationJsonBuilder.build(legal_aid_application).to_json }
        format.all { render plain: "Not found", status: :not_found }
      end
    end

    def generated_json
      respond_to do |format|
        format.json { render json: Datastore::PayloadGenerator.call(legal_aid_application).to_json }
        format.all { render plain: "Not found", status: :not_found }
      end
    end

    def submit
      datastore_id = Datastore::Submitter.call(legal_aid_application, token_object: current_provider.entra_id_token)

      flash[:notice] = "Submitted application \"#{legal_aid_application.application_ref}\" to datastore. It was given an id of \"#{datastore_id}\"."
      redirect_back_or_to(authenticated_root_path)
    rescue Datastore::Submitter::ApiError => e
      flash[:error] = e.message

      redirect_back_or_to(authenticated_root_path)
    rescue Datastore::Connection::RefreshTokenExpired
      current_provider.entra_id_token.presence&.destroy!
      sign_out current_provider

      # The most likely reasons for RefreshTokenExpired is reauthenticate period exceeded on the entraid level, so we show that page
      redirect_to session_expired_path(reason: :reauthenticate)
    end

  private

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(params[:legal_aid_application_id])
    end
  end
end
# :nocov:
