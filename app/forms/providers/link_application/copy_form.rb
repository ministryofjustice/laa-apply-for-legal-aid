module Providers
  module LinkApplication
    class CopyForm < BaseForm
      form_for LegalAidApplication

      attr_accessor :copy_case

      validates :copy_case, inclusion: [true, false, "true", "false"], unless: :draft?

      def save
        model.update!(copy_case_id: ActiveRecord::Type::Boolean.new.cast(copy_case) ? model.target_application.id : nil, linked_application_completed: true)
        model.proceedings.destroy_all if copy_case
        super
      end
      alias_method :save!, :save
    end
  end
end
