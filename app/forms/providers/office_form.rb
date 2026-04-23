module Providers
  class OfficeForm < BaseForm
    form_for Provider

    attr_accessor :selected_office_code

    validates :selected_office_code, presence: true
    validate :selected_code_was_provided

  private

    def selected_code_was_provided
      return if selected_office_code.nil?

      errors.add(:selected_office_code, :blank) unless selected_office_code.in?(model.office_codes)
    end
  end
end
