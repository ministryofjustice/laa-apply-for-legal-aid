module CFECivil
  module Components
    class Partner < BaseDataBlock
      delegate :partner, to: :legal_aid_application

      def call
        return {}.to_json if partner.blank?

        result = base_partner
        result.merge! JSON.parse(Components::CashTransactions.new(@legal_aid_application, "Partner").call) # so far... all other models are stored as Applicant/Partner
        result.merge! JSON.parse(Components::IrregularIncomes.new(@legal_aid_application, "Partner").call) # so far... all other models are stored as Applicant/Partner
        result.merge! JSON.parse(Components::Vehicles.new(@legal_aid_application, "partner").call) # this is stored as client/partner
        result.merge! JSON.parse(Components::Employments.new(@legal_aid_application, "Partner").call) # this is stored as Applicant/Partner
        result.merge! JSON.parse(Components::RegularTransactions.new(@legal_aid_application, "Partner").call) # this is stored as Applicant/Partner
        result.merge! JSON.parse(Components::Capitals.new(@legal_aid_application, "Partner").call) # this is stored as Applicant/Partner
        # employment_details # skipping this is a ccq datatype, we don't use it
        # self_employment_details # skipping this is a ccq datatype, we don't use it
        # Outgoings # skipped, these are generated from Truelayer and that is not currently supported by the partner flow
        # state_benefits # skipped, these are generated from Truelayer and that is not currently supported by the partner flow
        # other_incomes # skipped, these are generated from Truelayer and that is not currently supported by the partner flow
        # capitals # skipped, these are generated from Truelayer and that is not currently supported by the partner flow
        # additional_properties # skipping as this is submitted via client
        # dependants # skipping as this is submitted via client
        {
          partner: result,
        }.to_json
      end

    private

      def base_partner
        {
          partner: {
            date_of_birth: partner.date_of_birth.strftime("%Y-%m-%d"),
          },
        }
      end
    end
  end
end
