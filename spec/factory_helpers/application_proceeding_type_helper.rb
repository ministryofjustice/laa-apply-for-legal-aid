module FactoryHelpers
  class ApplicationProceedingTypeHelper
    # adds the proceeding_type and application_proceeding_type to the application, creating the proceeding type with the specified trait if it doesn't already exist
    # then adds the proceeding to the application
    #
    # e.g. ApplicationProceedingTypeHelper.add_proceeding_type(application: laa, ccms_cocde: 'DA001', trait: :with_real_data)
    def self.add_proceeding_type(application:, ccms_code:, trait:)
      proceeding_type = ProceedingType.find_by(ccms_code: ccms_code) || FactoryBot.create(:proceeding_type, trait)
      application.proceeding_types << proceeding_type
      ScopeLimitationsHelper.find_or_create_substantive_default(proceeding_type: proceeding_type)
      ScopeLimitationsHelper.find_or_create_delegated_functions_default(proceeding_type: proceeding_type)
      Proceeding.create_from_proceeding_type(application, proceeding_type) if application.proceedings.find_by(ccms_code: ccms_code).nil?
    end
  end

  class ScopeLimitationsHelper
    # find the default substantive scope limitation for the given proceeding_type, or creates one if it doesn't exist
    def self.find_or_create_substantive_default(proceeding_type:)
      ptsl = ProceedingTypeScopeLimitation.find_by(proceeding_type: proceeding_type, substantive_default: true)
      ptsl.nil? ? FactoryBot.create(:scope_limitation, :substantive_default, joined_proceeding_type: proceeding_type) : ptsl.scope_limitation
    end

    def self.find_or_create_delegated_functions_default(proceeding_type:)
      ptsl = ProceedingTypeScopeLimitation.find_by(proceeding_type: proceeding_type, delegated_functions_default: true)
      ptsl.nil? ? FactoryBot.create(:scope_limitation, :delegated_functions_default, joined_proceeding_type: proceeding_type) : ptsl.scope_limitation
    end
  end
end
