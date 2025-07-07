module TaskStatus
  module Validators
    class ProceedingsTypes < Base
      def valid?
        return false if proceedings.empty?

        super
      end

    private

      delegate :proceedings, to: :application

      def forms
        [
          client_involvement_type_forms,
          delegated_functions_forms,
          emergency_defaults_forms,
        ].flatten
      end

      def client_involvement_type_forms
        proceedings.map do |proceeding|
          Proceedings::ClientInvolvementTypeForm.new(model: proceeding)
        end
      end

      def delegated_functions_forms
        proceedings.map do |proceeding|
          Proceedings::DelegatedFunctionsForm.new(model: proceeding)
        end
      end

      def emergency_defaults_forms
        proceedings.map do |proceeding|
          next unless proceeding.uses_emergency_certificate?

          Proceedings::EmergencyDefaultsForm.new(model: proceeding)
        end
      end
    end
  end
end
