require "devise/hooks/reauthable"

module Devise
  mattr_accessor :reauthenticate_in

  module Models
    module Reauthable
      extend ActiveSupport::Concern

      def reauthenticate?
        current_sign_in_at < reauthenticate_in.ago
      end

      delegate :reauthenticate_in, to: :class

      module ClassMethods
        Devise::Models.config(self, :reauthenticate_in)
      end
    end
  end
end
