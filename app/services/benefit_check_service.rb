class BenefitCheckService
  BENEFIT_CHECKER_NAMESPACE = 'https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check'.freeze
  ApiError = Class.new(StandardError)

  def initialize(application)
    @application = application
    @config = Rails.configuration.x.benefit_check
  end

  def call
    soap_client.call(:check, message: benefit_checker_params).body.dig(:benefit_checker_response)
  rescue Savon::SOAPFault => e
    raise ApiError, "HTTP #{e.http.code}, #{e.to_hash}"
  rescue Net::ReadTimeout => e
    raise ApiError, e
  end

  private

  attr_reader :application, :config

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
      lscServiceName: config.service_name,
      clientOrgId: config.client_org_id,
      clientUserId: config.client_user_id
    }
  end

  def applicant
    application.applicant
  end

  def soap_client
    @soap_client ||= Savon.client(
      endpoint: config.wsdl_url,
      namespace: BENEFIT_CHECKER_NAMESPACE
    )
  end
end
