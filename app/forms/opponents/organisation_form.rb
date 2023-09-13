module Opponents
  class OrganisationForm < BaseForm
    form_for ApplicationMeritsTask::Opponent

    attr_accessor :name, :organisation_type_ccms_code, :description, :legal_aid_application

    validates :name, :organisation_type_ccms_code, presence: true, unless: :draft?

    def organisation_types
      @organisation_types ||= LegalFramework::OrganisationTypes::All.call
    end

    def save
      return false unless valid?

      model.legal_aid_application = legal_aid_application if legal_aid_application

      if model.opposable
        model.opposable.name = name
        model.opposable.ccms_type_code = organisation_type_ccms_code
        model.opposable.ccms_type_text = organisation_type_description
        model.opposable.save!
      else
        model.opposable = ApplicationMeritsTask::Organisation.new(name:, ccms_type_code: organisation_type_ccms_code, ccms_type_text: organisation_type_description)
      end
      model.save!(validate: false)
    end
    alias_method :save!, :save

  private

    def organisation_type
      organisation_types.find do |organisation_type|
        organisation_type.ccms_code == organisation_type_ccms_code
      end
    end

    def organisation_type_description
      organisation_type.description
    end
  end
end
