# :nocov:
module Test
  # This controller is used purely for generating an error so that we can
  # see it being reported in Sentry or Slack, according to the value in the Setting
  #
  class GenerateErrorController < ApplicationController
    def show
      raise 'Test Error Generated - to test the reporting of errors'
    end
  end
end
# :nocov:
