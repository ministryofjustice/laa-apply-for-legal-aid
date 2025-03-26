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

      # override in subclass
      def forms
        []
      end

      # override in subclass
      def validators
        []
      end
    end
  end
end
