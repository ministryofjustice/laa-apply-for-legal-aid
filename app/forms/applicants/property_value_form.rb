module Applicants
  class PropertyValueForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :property_value

    validates :property_value, presence: true, numericality: true
  end
end
