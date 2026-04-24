# Each time a record is retrieved from the session (:fetch)
# we check whether the `current_sign_in_at` is older than the
# `reauthenticate_in` value. If so, the record is logged out.
#
# NOTE: Do not sign out here as it will prvent the custom failure app triggering.
# However to prevent infinite redirect loops we set a flag in the session to indicate that we have triggered it
# then throw a message that triggers the custom failure app, in which we sign out and redirect.
#
# NOTE: initialally setting the flag to symbol which will be returned, as a string. Not sure if this is a
# a good dependency, needs mote investigation.
module Devise
  module Hooks
    module Reauthable
      Warden::Manager.after_set_user only: :fetch do |record, warden, options|
        scope = options[:scope]

        if warden.session(scope)["reauth_triggered"]
          warden.session(scope).delete("reauth_triggered")
          next
        end

        if warden.authenticated?(scope) &&
            record.respond_to?(:reauthenticate?) &&
            record.reauthenticate?

          warden.session(scope)[:reauth_triggered] = true
          throw :warden, scope: scope, message: :reauthenticate
        end
      end
    end
  end
end
