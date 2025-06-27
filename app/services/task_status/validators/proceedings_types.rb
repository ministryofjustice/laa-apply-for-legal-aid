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
          proceedings_types_form,
        ].flatten
      end

      def proceedings_types_form
        proceedings.map do |proceeding|
          Proceedings::ClientInvolvementTypeForm.new(model: proceeding)
        end
      end
    end
  end
end
