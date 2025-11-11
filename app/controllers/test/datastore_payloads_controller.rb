# :nocov:
module Test
  # This controller is used to render the payload that would be sent to the datastore.
  #
  # The test_datastore_payloads_path route is defined in development only
  #

  class DatastorePayloadsController < ApplicationController
    before_action :legal_aid_application

    def show
      respond_to do |format|
        format.json { render json: LegalAidApplicationJsonBuilder.build(legal_aid_application).to_json }
        format.all { render plain: "Not found", status: :not_found }
      end
    end

  private

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(params[:legal_aid_application_id])
    end
  end
end
# :nocov:
