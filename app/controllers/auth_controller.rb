class AuthController < ApplicationController
  def failure
    redirect_to error_path(:access_denied)
  end
end
