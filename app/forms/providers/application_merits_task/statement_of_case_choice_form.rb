module Providers
  module ApplicationMeritsTask
    class StatementOfCaseChoiceForm < BaseForm
      form_for ::ApplicationMeritsTask::StatementOfCase

      attr_accessor :statement, :upload, :typed, :choice

      validate :validate_any_checkbox_checked, unless: :draft?
      validates :statement, presence: true, if: :typed?

      set_callback :save, :before, :update_values

      def exclude_from_model
        [:choice]
      end

      def initialize(params = {})
        super
        %i[typed upload].each do |choice|
          value = params[choice].present? ? params[choice].include?("true") : params[:model].send(choice)
          send("#{choice}=", value)
        end
      end

    private

      def update_values
        attributes["upload"] = attributes["upload"].is_a?(Array) && attributes["upload"].include?("true")
        attributes["typed"] = attributes["typed"].is_a?(Array) && attributes["typed"].include?("true")
        attributes["statement"] = "" if attributes["typed"] == false
      end

      def typed?
        typed.is_a?(Array) ? typed.include?("true") : typed == true
      end

      def validate_any_checkbox_checked
        errors.add :upload, :blank unless any_checkbox_checked?
      end

      def any_checkbox_checked?
        %i[upload typed].index_with { |attribute| __send__(attribute) }.values.flatten.include?("true") ||
          %i[upload typed].index_with { |attribute| __send__(attribute) }.values.any?(&:present?)
      end
    end
  end
end
