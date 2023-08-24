# TODO: sort out loading of these
require Rails.root.join("app/services/ccms/requestors/base_requestor.rb")
require Rails.root.join("app/services/ccms/requestors/opponent_organisation_search_requestor.rb")

module Opponents
  class OrganisationForm < BaseForm
    form_for ApplicationMeritsTask::Opponent

    attr_accessor :name,
                  :organisation_type_ccms_code,
                  :description,
                  :legal_aid_application

    validates :name, :organisation_type_ccms_code, presence: true, unless: :draft?

    BlankRowStruct = Struct.new(:ccms_code, :description)

    def organisation_types
      @organisation_types ||= LegalFramework::OrganisationTypes::All.call.prepend(blank_row)
    end

    OrganisationStruct = Struct.new(:name, :type, :party_id, :name_and_type)

    def organisation_collection
      @organisation_collection ||=
        organisation_list
          .pluck(:organization_name, :organization_type, :organization_party_id)
          .sort_by { |el| el[0] }
          .each_with_object([]) do |el, memo|
            memo << OrganisationStruct.new(el[0], el[1], el[2], "#{el[0]} (#{el[1]})")
          end
    end

    def organisation_list
      @organisation_list ||= CCMS::Requestors::OpponentOrganisationSearchRequestor
        .new("TESTUSER11")
        .call
        .body[:common_org_inq_rs][:organization_list]
    end

    def save
      return false unless valid?

      model.legal_aid_application = legal_aid_application if legal_aid_application

      if model.opposable
        model.opposable.name = name
        model.opposable.ccms_code = organisation_type_ccms_code
        model.ccms_opponent_id = organisation_collection.find { |org| org.name == name }&.party_id
        model.opposable.description = organisation_type_description
        model.opposable.save!
      else
        model.opposable = ApplicationMeritsTask::Organisation.new(name:, ccms_code: organisation_type_ccms_code, description: organisation_type_description)
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

    def blank_row
      BlankRowStruct.new("", "")
    end
  end
end
