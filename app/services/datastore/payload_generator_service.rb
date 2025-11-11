module Datastore
  class PayloadGeneratorService
    attr_reader :legal_aid_application

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def call
      {
        application_reference:,
        status:,
        modified_at:,
        schema_version:,
        application_data:,
      }
    end

  private

    def application_reference
      legal_aid_application.application_ref
    end

    # TODO: could determine via state_machine?
    def status
      "submitted"
    end

    def modified_at
      legal_aid_application.updated_at.iso8601
    end

    # TODO: how would we version?
    def schema_version
      "v1"
    end

    def application_data
      @application_data ||= LegalAidApplicationJsonBuilder.build(legal_aid_application).to_json
    end
  end
end
