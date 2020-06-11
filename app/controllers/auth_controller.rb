class AuthController < ApplicationController
  class AuthorizationError < StandardError; end
  def failure
    begin
      raise AuthorizationError, 'Redirecting to access denied page'
    rescue StandardError => e
      Raven.capture_exception(e)
    end

    redirect_to error_path(:access_denied)
  end
end
