module TaskStatus
  module Validators
    class Base
      attr_reader :application

      delegate :applicant, to: :application
      delegate :address, to: :applicant

      def initialize(application)
        @application = application
      end

      def valid?
        forms.all?(&:valid?) &&
          validators.all?(&:valid?)
      end

    private

      # :nocov:
      # override in subclass
      def forms
        []
      end
      # :nocov:

      # :nocov:
      # override in subclass
      def validators
        []
      end
      # :nocov:
    end
  end
end
