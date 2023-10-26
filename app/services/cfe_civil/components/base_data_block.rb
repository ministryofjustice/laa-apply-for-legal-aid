module CFECivil
  module Components
    class BaseDataBlock
      attr_reader :legal_aid_application, :owner_type

      def self.call(legal_aid_application, owner_type = "Applicant")
        new(legal_aid_application, owner_type).call
      end

      def initialize(legal_aid_application, owner_type = "Applicant")
        @legal_aid_application = legal_aid_application
        @owner_type = owner_type
      end
    end
  end
end
