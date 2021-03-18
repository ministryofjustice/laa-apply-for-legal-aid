FactoryBot.define do
  factory :ccms_submission_history, class: CCMS::SubmissionHistory do
    submission

    from_state { 'initialised' }
    to_state { 'case_ref_obtained' }
    success { Faker::Boolean.boolean }
    details { Faker::Lorem.word }
    request { Faker::Lorem.word }
    response { Faker::Lorem.word }

    trait :without_xml do
      request { nil }
      response { nil }
    end

    trait :with_xml do
      request { File.open(Rails.root.join('ccms_integration/example_payloads/NonPassportedFullMonty.xml')) { |f| Nokogiri::XML(f).remove_namespaces! } }
      response do
        '<?xml version="1.0" encoding="UTF-8"?>
      <soap:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns2="http://legalservices.gov.uk/CCMS/Common/ReferenceData/1.0/ReferenceDataBIM"
      xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:ns3="http://legalservices.gov.uk/Enterprise/Common/1.0/Header"
      xmlns:ns4="http://legalservices.gov.uk/Enterprise/Common/1.0/Common" xmlns:ns5="http://legalservices.gov.uk/CCMS/Common/ReferenceData/1.0/ReferenceDataBIO">
        <soap:Header>
          <ns1:Security>
            <ns1:UsernameToken>
              <ns1:Username/>
              <ns1:Password Type=""></ns1:Password>
            </ns1:UsernameToken>
          </ns1:Security>
        </soap:Header>
        <soap:Body>
          <ns2:ReferenceDataInqRQ>
            <ns3:HeaderRQ>
              <ns3:TransactionRequestID>202011191634055689868875843</ns3:TransactionRequestID>
              <ns3:Language>ENG</ns3:Language>
              <ns3:UserLoginID>MARTIN.RONAN@DAVIDGRAY.CO.UK</ns3:UserLoginID>
              <ns3:UserRole/>
            </ns3:HeaderRQ>
            <ns2:SearchCriteria>
              <ns5:ContextKey>CaseReferenceNumber</ns5:ContextKey>
              <ns5:SearchKey>
                <ns5:Key>CaseReferenceNumber</ns5:Key>
              </ns5:SearchKey>
            </ns2:SearchCriteria>
          </ns2:ReferenceDataInqRQ>
        </soap:Body>
      </soap:Envelope>
      '
      end
    end
  end
end
