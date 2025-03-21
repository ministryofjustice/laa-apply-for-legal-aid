module TaskStatus
  module Validators
    class LinkedApplications
      def initialize(application)
        @application = application
      end

      # TODO: what constitutes a valid and complete series of anwsers to linked application questions
      def valid?
        true
      end

    private

      attr_reader :application
    end
  end
end
