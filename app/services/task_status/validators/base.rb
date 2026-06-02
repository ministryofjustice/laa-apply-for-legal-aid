module TaskStatus
  module Validators
    class Base
      attr_reader :application

      delegate :applicant, :dwp_override, to: :application
      delegate :address, to: :applicant

      def initialize(application, test_progression: false)
        @application = application
        @test_progression = test_progression
      end

      def valid?
        if @test_progression
          arr = []
          forms.each_key do |section|
            forms[section].each_key do |task|
              forms[section][task].each do |form|
                arr.append(application.legal_aid_application_progression.derek[section][task]["forms"][form]["valid"])
              end
            end
          end
          arr.all? &&
            validators.all?(&:valid?)
        else
          forms.all?(&:valid?) &&
            validators.all?(&:valid?)
        end
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
