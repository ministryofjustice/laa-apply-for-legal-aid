module Providers
  module Means
    module ApplicantOwner
      def owner
        legal_aid_application&.applicant
      end
    end
  end
end
