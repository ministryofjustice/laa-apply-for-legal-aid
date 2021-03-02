module Providers
  class HasOtherProceedingsForm
    include ActiveModel::Model

    attr_accessor :has_other_proceedings

    validate :other_proceedings_present?

    def other_proceedings_present?
      errors.add :has_other_proceedings, error_message if has_other_proceedings.blank?
    end

    def error_message
      I18n.t('providers.has_other_proceedings.show.error')
    end
  end
end
