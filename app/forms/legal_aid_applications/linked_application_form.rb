module LegalAidApplications
  class LinkedApplicationForm < BaseForm
    form_for LegalAidApplication

    attr_reader :link_types

    attr_accessor :linked_application_ref, :legal_aid_application, :link_type_code, :has_linked_application

    validate :valid_linked_application_ref
    validates :link_type_code, presence: true, if: :linked_application?

    LinkType = Struct.new(:link_type_code, :description)

    def initialize(*args)
      super
      @link_types = []
      # TODO: confirm desccriptions and codes and move to LFA
      @link_types << LinkType.new(link_type_code: "FAMILY", description: "Family")
      @link_types << LinkType.new(link_type_code: "LEGAL", description: "Legal")
    end

    def save
      return false unless valid?
      return true unless linked_application?

      LinkedApplication.create!(lead_application: application_to_link, associated_application: model, link_description: "Family", link_type_code: "FAM")
    end

  private

    def valid_linked_application_ref
      return unless linked_application?
      return if application_to_link

      errors.add(:linked_application_ref, "Invalid application ref")
    end

    def linked_application?
      !draft? && has_linked_application.to_s == "true"
    end

    def application_to_link
      @application_to_link ||= provider.legal_aid_applications.find_by(application_ref: linked_application_ref)
    end

    def provider
      @provider ||= model.provider
    end
  end
end
