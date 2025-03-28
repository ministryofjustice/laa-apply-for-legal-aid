module TaskStatus
  module Validators
    class ProceedingsTypes < Base
      def valid?
        return false if proceedings.empty?

        results = proceedings.each_with_object([]) do |proceeding, arr|
          arr << valid_proceeding?(proceeding)
        end

        results.all?
      end

    private

      delegate :proceedings, to: :application

      # TODO: what constitutes a valid proceeding
      # handle delegated functions, levels of service etc.
      #
      def valid_proceeding?(proceeding)
        [
          proceeding.ccms_code.present?,
          proceeding.meaning.present?,
          proceeding.matter_type.present?,
          proceeding.category_of_law.present?,
          proceeding.category_law_code.present?,
          proceeding.used_delegated_functions.in?([true, false]),
          proceeding.client_involvement_type_ccms_code.present?,
          proceeding.client_involvement_type_description.present?,
        ].all?
      end
    end
  end
end
