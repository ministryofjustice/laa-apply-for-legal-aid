module Addresses
  class CareOfForm < BaseForm
    form_for Address

    attr_accessor :care_of, :care_of_first_name, :care_of_last_name, :care_of_organisation_name

    validates :care_of, presence: true, unless: :draft?
    validates :care_of_first_name, :care_of_last_name, presence: true, if: :person_name_required?
    validates :care_of_organisation_name, presence: true, if: :organisation_name_required?

  private

    def person_name_required?
      !draft? && care_of == "person"
    end

    def organisation_name_required?
      !draft? && care_of == "organisation"
    end
  end
end
