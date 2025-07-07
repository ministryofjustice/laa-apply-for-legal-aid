# ApplicationTrackable
#
# The idea here is to store the fact that (and when) a page or thing
# has been visited, reviewed or otherwise "handled" when no other
# data exists that can provide this information easily or reliably.
#
# This was created to track completion of the CYA pages primarily
# but may be useful more generally.
#
module Providers
  module ApplicationTrackable
    extend ActiveSupport::Concern

    class_methods do
      attr_reader :tracked_name

      def track_as(tracked_name)
        @tracked_name = tracked_name
      end
    end

    included do
      def tracked_name
        self.class.tracked_name
      end

      def track_now!
        legal_aid_application.tracked[tracked_name] = Time.current
        legal_aid_application.save!
      end

      def untrack!(tracked_name)
        return unless tracked_name && legal_aid_application.tracked.include?(tracked_name)

        legal_aid_application.tracked[tracked_name] = nil
        legal_aid_application.save!
      end
    end
  end
end
