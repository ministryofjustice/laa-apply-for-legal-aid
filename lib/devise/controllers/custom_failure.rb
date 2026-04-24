module Devise
  module Controllers
    class CustomFailure < Devise::FailureApp
      def redirect_url
        case warden_message
        when :timeout
          # already signed out by timeoutable
          session_expired_path(reason: warden_message)
        when :reauthenticate
          # not yet signed out by reauthauthable
          proxy = Devise::Hooks::Proxy.new(warden)
          Devise.sign_out_all_scopes ? proxy.sign_out : proxy.sign_out(scope)
          session_expired_path(reason: warden_message)
        else
          super
        end
      end
    end
  end
end
