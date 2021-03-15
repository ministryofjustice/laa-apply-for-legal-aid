module Providers
  class CheckClientDetailsForm
    include ActiveModel::Model

    attr_accessor :check_client_details

    validate :check_client_details_present?

    private

    def check_client_details_present?
      errors.add :check_client_details, error_message if check_client_details.blank?
    end

    def error_message
      I18n.t('providers.check_client_details.show.error')
    end
  end
end
