class V1::ApplicationsController < ApplicationController


  def create

    legalaid_application = LegalAidApplication.new

    if legalaid_application.save
      #TODO figure out why this render function doesnt automatically use  the serializer.
      render json: LegalAidApplicationSerializer.new(legalaid_application).serialized_json, status: :created, serializer: LegalAidApplicationSerializer
    else
      # TODO probably a better way to do this error return something like a global errrors handler if save fails
      render json: {status: 'ERROR', message: 'Failed to create application', data: legalaid_application.errors}, status: :bad_request
    end

    # respond_with @legalaid_application
  end
end
