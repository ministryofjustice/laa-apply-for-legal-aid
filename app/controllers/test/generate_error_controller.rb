module Test
  # This controller is used purely for generating an error so that we can
  # see it being reported in Sentry or Slack, according to the value in the Setting
  #
  class GenerateErrorController < ApplicationController
    def trapped_error
      raise "Test Error Generated - to test the reporting of errors"
    rescue StandardError => e
      AlertManager.capture_exception(e)
      redirect_to submitted_providers_legal_aid_applications_path
    end

    def untrapped_error
      raise "Untrapped Test Error generated"
    end
  end
end
