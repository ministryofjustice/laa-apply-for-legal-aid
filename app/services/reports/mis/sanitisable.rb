module Reports
  module MIS
    module Sanitisable
      def sanitise
        @line.map { |field| sanitise_field(field) }
      end

      def sanitise_field(field)
        field.nil? || field.is_a?(Numeric) ? field : prefix_if_necessary(field)
      end

      def prefix_if_necessary(field)
        starts_with_special_character?(field.to_s) ? prefix(field.to_s) : field
      end

      def starts_with_special_character?(str)
        %w[= + - @ %].include?(str.first)
      end

      def prefix(field)
        "'#{field}"
      end
    end
  end
end
