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
          client_involvement_type_form,
          delegated_functions_form,
        ].flatten
      end

      def client_involvement_type_form
        proceedings.map do |proceeding|
          Proceedings::ClientInvolvementTypeForm.new(model: proceeding)
        end
      end

      def delegated_functions_form
        proceedings.map do |proceeding|
          Proceedings::DelegatedFunctionsForm.new(model: proceeding)
        end
      end
    end
  end
end
