module Addresses
  class CareOfForm < BaseForm
    form_for Address

    attr_accessor :care_of, :care_of_first_name, :care_of_last_name, :care_of_organisation_name

    validates :care_of,
              presence: true,
              unless: :draft?
  end
end
