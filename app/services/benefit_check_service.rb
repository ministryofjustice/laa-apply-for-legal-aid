class BenefitCheckService
  BENEFIT_CHECKER_NAMESPACE = 'https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check'.freeze

  attr_reader :application

  def initialize(application)
    @application = application
  end

  def check_benefits
    benefit_checker_params =
      { lscServiceName: ENV['BC_LSC_SERVICE_NAME'],
        clientOrgId: ENV['BC_CLIENT_ORG_ID'],
        clientUserId: ENV['BC_CLIENT_USER_ID'],
        clientReference: application.id,
        nino: applicant.national_insurance_number,
        surname: applicant.last_name,
        dateOfBirth: applicant.date_of_birth.strftime("%Y%m%d"),
        dateOfAward: Date.today.strftime("%Y%m%d") }

    soap_client.call(:check, message: benefit_checker_params).body.dig(:benefit_checker_response)
  end

  private

  def applicant
    @applicant ||= application.applicant
  end

  def soap_client
    @soap_client ||= Savon.client(
      env_namespace: :soapenv,
      wsdl: ENV['BC_WSDL_URL'],
      namespaces: { 'xmlns:ins0' => BENEFIT_CHECKER_NAMESPACE }
    )
  end
end
