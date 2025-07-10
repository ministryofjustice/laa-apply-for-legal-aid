# Reviewable
#
# The idea here is to store the fact that (and when) a page or thing
# has been visited, reviewed or otherwise "handled" when no other
# data exists that can provide this information easily or reliably.
#
# This was created to track completion of the CYA pages primarily
# but may be useful more generally.
#
module Reviewable
  module Controller
    extend ActiveSupport::Concern

    class_methods do
      attr_reader :reviewable_object, :reviewable_name

      def review_as(reviewable_object, reviewable_name)
        @reviewable_object = reviewable_object
        @reviewable_name = reviewable_name
      end
      alias_method :reviewed_by, :review_as
    end

    included do
      def reviewable_object
        self.class.reviewable_object
      end

      def reviewable_name
        self.class.reviewable_name
      end

      def review_in_progress!
        send(reviewable_object).review_in_progress!(reviewable_name)
      end

      def review_completed!
        send(reviewable_object).review_completed!(reviewable_name)
      end

      def unreview!
        send(reviewable_object).unreview!(reviewable_name)
      end
    end
  end
end
