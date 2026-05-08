# Each time a record is retrieved from the session (:fetch)
# we check whether the `current_sign_in_at` is older than the
# `reauthenticate_in` value. If so, we throw a :warden exception
# that is then handled by the custom failure app.
#
# NOTE: Do not sign out here as it will prevent the custom failure
# app triggering, which is responsible for signing out and redirecting
# to the custom session expired page.
#
module Devise
  module Hooks
    module Reauthable
      Warden::Manager.after_set_user only: :fetch do |record, warden, options|
        scope = options[:scope]

        if warden.authenticated?(scope) &&
            record.respond_to?(:reauthenticate?) &&
            record.reauthenticate?

          throw :warden, scope: scope, message: :reauthenticate
        end
      end
    end
  end
end
