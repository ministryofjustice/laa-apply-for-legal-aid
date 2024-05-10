module Providers
  module LinkApplication
    class CopyForm < BaseForm
      form_for LegalAidApplication

      attr_accessor :copy_case

      validates :copy_case, presence: true, unless: :draft?

      def save
        model.update!(copy_case_id: ActiveRecord::Type::Boolean.new.cast(copy_case) ? model.lead_application.id : nil)
        model.proceedings.destroy_all if copy_case
        super
      end
      alias_method :save!, :save
    end
  end
end
