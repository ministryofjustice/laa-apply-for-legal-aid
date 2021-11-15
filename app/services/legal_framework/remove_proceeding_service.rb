module LegalFramework
  class RemoveProceedingService
    def self.call(legal_aid_application, proceeding)
      new(legal_aid_application, proceeding).call
    end

    def initialize(legal_aid_application, proceeding)
      @legal_aid_application = legal_aid_application
      @proceeding = proceeding
    end

    def call
      @proceeding.destroy!
    end
  end
end
