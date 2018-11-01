class BenefitCheckService
  BENEFIT_CHECKER_NAMESPACE = 'https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check'.freeze

  attr_reader :application

  def initialize(application)
    @application = application
  end

  def check_benefits
    soap_client.call(:check, message: benefit_checker_params).body.dig(:benefit_checker_response)
  end

  private

  def benefit_checker_params
    {
      clientReference: application.id,
      nino: applicant.national_insurance_number,
      surname: applicant.last_name.strip.upcase,
      dateOfBirth: applicant.date_of_birth.strftime('%Y%m%d'),
      dateOfAward: Date.today.strftime('%Y%m%d')
    }.merge(credential_params)
  end

  def credential_params
    {
      lscServiceName: Rails.configuration.x.benefit_check.service_name,
      clientOrgId: Rails.configuration.x.benefit_check.client_org_id,
      clientUserId: Rails.configuration.x.benefit_check.client_user_id
    }
  end

  def applicant
    application.applicant
  end

  def soap_client
    @soap_client ||= Savon.client(
      env_namespace: :soapenv,
      wsdl: Rails.configuration.x.benefit_check.wsdl_url,
      namespaces: { 'xmlns:ins0' => BENEFIT_CHECKER_NAMESPACE }
    )
  end
end
