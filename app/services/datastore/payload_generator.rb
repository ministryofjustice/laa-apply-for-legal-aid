module Datastore
  class PayloadGenerator
    attr_reader :legal_aid_application

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def call
      transformer.call(payload)
    end

  private

    def payload
      {
        application_reference:,
        status:,
        schema_version:,
        application_content:,
      }
    end

    def application_reference
      legal_aid_application.application_ref
    end

    # TODO: could determine via state_machine?
    def status
      "SUBMITTED"
    end

    # TODO: how would we version?
    def schema_version
      0
    end

    def application_content
      @application_content ||= transformer.call(legal_aid_application_hash).to_json
    end

    def legal_aid_application_hash
      @legal_aid_application_hash ||= LegalAidApplicationJsonBuilder.build(legal_aid_application).as_json
    end

    def transformer
      Transformer
    end
  end
end
