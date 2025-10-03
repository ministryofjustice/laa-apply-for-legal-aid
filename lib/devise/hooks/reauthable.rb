# Each time a record is retrieved from the session (:fetch)
# we check whether the `current_sign_in_at` is older than the
# `reauthenticate_in` value. If so, the record is logged out.
#
module Devise
  module Hooks
    module Reauthable
      Warden::Manager.after_set_user only: :fetch do |record, warden, options|
        scope = options[:scope]

        if warden.authenticated?(scope) &&
            record.respond_to?(:reauthenticate?) &&
            record.reauthenticate?

          proxy = Devise::Hooks::Proxy.new(warden)

          Devise.sign_out_all_scopes ? proxy.sign_out : proxy.sign_out(scope)
          throw :warden, scope: scope, message: :reauthenticate
        end
      end
    end
  end
end
