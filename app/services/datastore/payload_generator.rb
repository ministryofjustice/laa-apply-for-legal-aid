module Datastore
  class PayloadGenerator
    attr_reader :legal_aid_application, :transformer

    def initialize(legal_aid_application, transformer: Transformer)
      @legal_aid_application = legal_aid_application
      @transformer = transformer
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
        laa_reference:,
        status:,
        application_content:,
        individuals:,
      }
    end

    def laa_reference
      legal_aid_application.application_ref
    end

    # Valid values at time of writing: "APPLICATION_IN_PROGRESS", "APPLICATION_SUBMITTED"
    # NOTE: sending an invalid value results in a 400 from datastore
    def status
      Constants.status_value(legal_aid_application.summary_state)
    end

    def application_content
      @application_content ||= legal_aid_application_hash
    end

    # TMP/TODO: Curently just supplying client/application but this may be in future used to also provide
    # partner, opponents and involved children?!
    def individuals
      [individuals_hash]
    end

    def individuals_hash
      IndividualPolymorphJsonBuilder.build(legal_aid_application.applicant).as_json
    end

    def legal_aid_application_hash
      @legal_aid_application_hash ||= LegalAidApplicationJsonBuilder.build(legal_aid_application).as_json
    end
  end
end
