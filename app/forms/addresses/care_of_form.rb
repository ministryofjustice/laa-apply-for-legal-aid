module Addresses
  class CareOfForm < BaseForm
    form_for Address

    attr_accessor :care_of, :care_of_first_name, :care_of_last_name, :care_of_organisation_name

    validates :care_of, presence: true, unless: :draft?
    validates :care_of_first_name, :care_of_last_name, presence: true, if: :person_name_required?
    validates :care_of_organisation_name, presence: true, if: :organisation_name_required?

    def save
      delete_care_of_information if care_of.eql?("no")
      super
    end
    alias_method :save!, :save

  private

    def delete_care_of_information
      attributes["care_of_first_name"] = nil
      attributes["care_of_last_name"] = nil
      attributes["care_of_organisation_name"] = nil
    end

    def person_name_required?
      !draft? && care_of == "person"
    end

    def organisation_name_required?
      !draft? && care_of == "organisation"
    end
  end
end
