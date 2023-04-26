module Providers
  class ConfirmDwpNonPassportedForm < BaseForm
    form_for Provider

    attr_accessor :correct_dwp_result

    validates :selected_office_id, presence: true
  end
end
