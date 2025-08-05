module Providers
  class OfficeForm < BaseForm
    form_for Provider

    attr_accessor :selected_office_code

    validates :selected_office_code, presence: true
  end
end
