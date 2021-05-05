class BenefitCheckService
  BENEFIT_CHECKER_NAMESPACE = 'https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check'.freeze
  USE_MOCK = ActiveModel::Type::Boolean.new.cast(Rails.configuration.x.bc_use_dev_mock)
  REQUEST_TIMEOUT = 30.seconds

  class ApiError < StandardError
    include Nesty::NestedError
  end

  def self.call(application)
    return MockBenefitCheckService.call(application) if USE_MOCK && !Rails.env.production?

    new(application).call
  end

  def initialize(application)
    @application = application
    @config = Rails.configuration.x.benefit_check
  end

  def call
    soap_client.call(:check, message: benefit_checker_params).body[:benefit_checker_response]
  rescue Savon::SOAPFault => e
    Sentry.capture_exception(ApiError.new("HTTP #{e.http.code}, #{e.to_hash}"))
    false
  rescue StandardError => e
    Sentry.capture_exception(e)
    false
  end

  private

  attr_reader :application, :config

  def benefit_checker_params
    {
      clientReference: application.id,
      nino: applicant.national_insurance_number,
      surname: applicant.last_name.strip.upcase,
      dateOfBirth: applicant.date_of_birth.strftime('%Y%m%d'),
      dateOfAward: Time.zone.today.strftime('%Y%m%d')
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
      open_timeout: REQUEST_TIMEOUT,
      read_timeout: REQUEST_TIMEOUT,
      namespace: BENEFIT_CHECKER_NAMESPACE
    )
  end
end
