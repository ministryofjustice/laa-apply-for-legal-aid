module Proceedings
  class ProceedingsTypesForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :ccms_code
  end
end
