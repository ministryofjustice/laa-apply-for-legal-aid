class BenefitCheckService
  class BenefitCheckError < StandardError; end

  USE_MOCK = ActiveModel::Type::Boolean.new.cast(Rails.configuration.x.bc_use_dev_mock)
  NAMESPACES = {
    "xmlns:xsd": "http://www.w3.org/2001/XMLSchema",
    "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
    "xmlns:wsdl": "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check",
    "xmlns:env": "http://schemas.xmlsoap.org/soap/envelope/",
  }.freeze

  def self.call(application)
    return MockBenefitCheckService.call(application) if USE_MOCK && !Rails.env.production?

    new(application).call
  end

  def initialize(application)
    @application = application
    @config = Rails.configuration.x.benefit_check
  end

  def call
    soap = Faraday::SoapCall.new(Rails.configuration.x.benefit_check.wsdl_url, :benefit_checker)
    response = soap.call(request_xml)
    result = Hash.from_xml(response).deep_transform_keys { |key| key.underscore.to_sym }
    if result.dig(:envelope, :body, :fault)
      error_message = "BenefitCheckError: #{result.dig(:envelope, :body, :fault, :detail, :benefit_checker_fault_exception, :message_text)}"
      raise BenefitCheckError, error_message
    end

    result.dig(:envelope, :body, :benefit_checker_response)
  rescue Faraday::SoapError
    false
  rescue BenefitCheckError => e
    AlertManager.capture_exception(e)
    Rails.logger.error(e.message)
    false
  end

private

  attr_reader :application, :config

  def benefit_checker_params
    {
      clientReference: application.id,
      nino: applicant.national_insurance_number,
      surname: applicant.last_name.strip.upcase,
      dateOfBirth: applicant.date_of_birth.strftime("%Y%m%d"),
      dateOfAward: Time.zone.today.strftime("%Y%m%d"),
    }.merge(credential_params)
  end

  def credential_params
    {
      lscServiceName: config.service_name,
      clientOrgId: config.client_org_id,
      clientUserId: config.client_user_id,
    }
  end

  def applicant
    application.applicant
  end

  def soap_envelope
    Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
      xml.__send__(:"env:Envelope", NAMESPACES) do
        xml.__send__(:"env:Body") do
          xml.__send__(:"wsdl:check") do
            benefit_checker_params.each do |key, value|
              xml.__send__(key.to_sym, value)
            end
          end
        end
      end
    end
  end

  def request_xml
    @request_xml ||= soap_envelope.to_xml.squish.chomp
  end
end
