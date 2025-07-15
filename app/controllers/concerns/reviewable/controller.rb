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
      attr_reader :reviewable_object, :reviewable_name, :execute_unreview

      def review_as(reviewable_object, reviewable_name)
        @execute_unreview = false
        @reviewable_object = reviewable_object
        @reviewable_name = reviewable_name
      end

      def reviewed_by(reviewable_object, reviewable_name)
        @execute_unreview = true
        @reviewable_object = reviewable_object
        @reviewable_name = reviewable_name
      end
    end

    included do
      before_action :unreview_on_update!

      def reviewable_object
        self.class.reviewable_object
      end

      def reviewable_name
        self.class.reviewable_name
      end

      def execute_unreview
        self.class.execute_unreview
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

      # Only execute the before action callback for controllers that have use reviewed_by, have supplied reviewable details
      # and if it is the update action being called. This does not take account of "Save and come back later" (draft calls.)
      def unreview_on_update!
        if execute_unreview && reviewable_object && reviewable_name && (action_name == "update")
          unreview!
        end
      end
    end
  end
end
