class AuthController < ApplicationController
  class AuthorizationError < StandardError; end

  def failure # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # redirect to consents page if it was an applicant failing to login at his bank
    #
    puts ">>>>>>>>>>>> OMNIAUTH FAILYER #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
    ap request.env['omniauth.auth']
    puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
    ap params.to_unsafe_hash
    puts ">>>>>>>>>>>> ^^^^^^^^^^^^^^^^ #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"

    if auth_error_during_bank_login?
      begin
        raise AuthorizationError, "Redirecting to access denied page - unexpected origin: '#{origin}'"
      rescue StandardError => e
        Raven.capture_exception(e)
      end
      redirect_to error_path(:access_denied)
    else
      redirect_to citizens_consent_path(auth_failure: true)
    end
  end

  private

  def origin
    @origin ||= params[:origin]
  end

  def auth_error_during_bank_login?
    return true if origin.nil?

    URI(origin).path != '/citizens/banks'
  end
end
