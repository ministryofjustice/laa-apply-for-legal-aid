class AuthController < ApplicationController
  class AuthorizationError < StandardError; end
  def failure
    Raven.capture_exception(AuthorizationError.new('Redirecting to access denied page'))
    redirect_to error_path(:access_denied)
  end
end
